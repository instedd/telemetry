module InsteddTelemetry
  class UploadProcess

    def initialize(period, server_url)
      raise "Undefined period"           unless period.present?
      raise "Undefined server URL"       unless server_url.present?
      raise "Period hasn't finished yet" unless period.already_finished?
      
      @period = period
      @server_url = URI.parse(server_url)
    end

    def run
      post stats and mark_period_as_sent unless @period.stats_already_sent?
    end

    def post(stats)
      # Ruby 1.9.3 requires url to be passed as string for Post.new
      req = Net::HTTP::Post.new(@server_url.to_s, {'Content-Type' =>'application/json'})
      req.body = stats.to_json

      response = Net::HTTP.new(@server_url.hostname, @server_url.port).request(req)
      return response.code == "200"
    end

    def stats
      counters = Counter.where(period_id: @period.id)
      set_occurrences = SetOccurrence.where(period_id: @period.id)

      {
        "counters" => counters_json(counters),
        "sets" => sets_json(set_occurrences)
      }
    end

    def mark_period_as_sent
      @period.stats_sent_at = Time.now.utc
      @period.save!
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

    def self.start_upload_process
      while true
        begin
          server_url = InsteddTelemetry.configuration.server_url
          
          InsteddTelemetry::Period.lock_for_upload do |periods|
            if periods.any?
              periods.each do |p|
                UploadProcess.new(p, server_url).run
              end
            else
              Logging.log :info, "There is no new information to upload"
            end
          end
        rescue Exception => e
          Logging.log_exception e, "An error occurred while trying to upload usage stats"
        end
        sleep 1.hour
      end
    end

    def self.current_period
      if current_period_cached
        @current_period
      else
        @current_period = InsteddTelemetry::Period.current
      end
    end

    def self.current_period_cached
      !Rails.env.test? && @current_period && DateTime.now < @current_period.end
    end

  end
end
