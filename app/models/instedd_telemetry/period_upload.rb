module InsteddTelemetry
  class PeriodUpload

    def initialize(period, pull_collectors = [])
      raise "Undefined period"           unless period.present?
      raise "Period hasn't finished yet" unless period.already_finished?

      @period = period
      @pull_collectors = pull_collectors
    end

    def collect_pull_stats_with(collectors)
      @pull_collectors += collectors
    end

    def run
      post stats and mark_period_as_sent unless @period.stats_already_sent?
    end

    def post(stats)
      response = InsteddTelemetry.api.create_event(stats)
      return response.code == "200"
    end

    def stats
      @pull_collectors.inject(pushed_stats_json) do |result, collector|
        collector_stats = collector.collect_stats(@period).with_indifferent_access

        result.tap do |r|
          r["counters"].concat(collector_stats["counters"])   if collector_stats["counters"]
          r["sets"].concat(collector_stats["sets"])           if collector_stats["sets"]
          r["timespans"].concat(collector_stats["timespans"]) if collector_stats["timespans"]
        end
      end
    end

    def pushed_stats_json
      counters = Counter.where(period_id: @period.id)
      set_occurrences = SetOccurrence.where(period_id: @period.id)
      timespans = Timespan.where(period_id: @period.id)
      {
        "period" =>  {
          "beginning" => @period.beginning.iso8601,
          "end" => @period.end.iso8601
        },
        "application" => InsteddTelemetry.application,
        "counters" => counters_json(counters),
        "sets" => sets_json(set_occurrences),
        "timespans" => timespans_json(timespans)
      }
    end

    def counters_json(counters)
      counters.map do |c|
        {
          "metric" => c.bucket,
          "key" => c.parse_key_attributes,
          "value" => c.count
        }
      end
    end

    def sets_json(sets)
      sets.group_by{|occ| [occ.bucket, occ.parse_key_attributes]}.map do |key, occurrences|
        {
          "metric" => key[0],
          "key" => key[1],
          "elements" => occurrences.map(&:element)
        }
      end
    end

    def timespans_json(timespans)
      timespans.map do |ts|
        {
          "metric" => ts.bucket,
          "key" => ts.parse_key_attributes,
          "days" => (ts.until - ts.since) / 1.day
        }
      end
    end

    def mark_period_as_sent
      @period.stats_sent_at = Time.now.utc
      @period.save!
    end

    def self.start_background_process
      while true
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            if !InsteddTelemetry.upload_enabled
              Logging.log :info, "User opted-out of telemetry report uploads, will not upload usage information."
            else
              InsteddTelemetry.update_installation
              InsteddTelemetry.ensure_period_exists
              custom_collectors = InsteddTelemetry.configuration.collectors

              InsteddTelemetry::Period.lock_for_upload do |periods|
                if periods.any?
                  periods.each do |p|
                    PeriodUpload.new(p, custom_collectors).run
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
        end
        sleep InsteddTelemetry.configuration.process_run_interval
      end
    end

  end
end
