module InsteddTelemetry
  class PeriodUpload

    def initialize(period, server_url, pull_collectors = [])
      raise "Undefined period"           unless period.present?
      raise "Undefined server URL"       unless server_url.present?
      raise "Period hasn't finished yet" unless period.already_finished?
      
      @period = period
      @server_enpoint = URI.join(server_url, "/api/v1/installations/#{InsteddTelemetry.instance_id}/events")
      @pull_collectors = pull_collectors
    end

    def collect_pull_stats_with(collectors)
      @pull_collectors += collectors
    end

    def run
      post stats and mark_period_as_sent unless @period.stats_already_sent?
    end

    def post(stats)
      # Ruby 1.9.3 requires url to be passed as string for Post.new
      req = Net::HTTP::Post.new(@server_enpoint.to_s, {'Content-Type' =>'application/json'})
      req.body = stats.to_json

      response = Net::HTTP.new(@server_enpoint.hostname, @server_enpoint.port).request(req)
      return response.code == "200"
    end

    def stats
      @pull_collectors.inject(pushed_stats_json) do |result, collector|
        collector_stats = collector.collect_stats(@period)

        result.tap do |r|
          r["counters"].concat(collector_stats["counters"]) if collector_stats["counters"]
          r["sets"].concat(collector_stats["sets"])         if collector_stats["sets"]
        end
      end
    end

    def pushed_stats_json
      counters = Counter.where(period_id: @period.id)
      set_occurrences = SetOccurrence.where(period_id: @period.id)

      {
        "period" =>  {
          "beginning" => @period.beginning.iso8601,
          "end" => @period.end.iso8601
        },
        "counters" => counters_json(counters),
        "sets" => sets_json(set_occurrences)
      }
    end

    def counters_json(counters)
      counters.map do |c|
        {
          "type" => c.bucket,
          "key" => JSON.parse(c.key_attributes),
          "value" => c.count
        }
      end
    end

    def sets_json(sets)
      sets.group_by{|occ| [occ.bucket, occ.key_attributes]}.map do |key, occurrences|
        {
          "type" => key[0],
          "key" => key[1],
          "elements" => occurrences.map(&:element)
        }
      end
    end

    def mark_period_as_sent
      @period.stats_sent_at = Time.now.utc
      @period.save!
    end

    def self.start_background_process
      while true
        begin
          if !InsteddTelemetry.upload_enabled
            Logging.log :info, "User opted-out of telemetry report uploads, will not upload usage information."
          else
            server_url = InsteddTelemetry.configuration.server_url
            custom_collectors = InsteddTelemetry.configuration.collectors

            InsteddTelemetry::Period.lock_for_upload do |periods|
              if periods.any?
                periods.each do |p|
                  PeriodUpload.new(p, server_url, custom_collectors).run
                  Logging.log :info, "Uploaded information for period #{p.beginning}-#{p.end}"
                end
              else
                Logging.log :info, "There is no new information to upload"
              end
            end
          end
        rescue Exception => e
          Logging.log_exception e, "An error occurred while trying to upload usage stats"
        end
        sleep 1.hour
      end
    end

  end
end
