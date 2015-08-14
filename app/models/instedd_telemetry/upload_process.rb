module InsteddTelemetry
  class UploadProcess

    def initialize(period, server_url)
      raise "Undefined period"           unless period.present?
      raise "Undefined server URL"       unless server_url.present?
      raise "Period hasn't finished yet" unless period.already_finished?
      
      @period = period
      @server_url = server_url
    end

    def run
      post stats and mark_period_as_sent unless @period.stats_already_sent?
    end

    def post(stats)
      uri = URI.parse(@server_url)
      req = Net::HTTP::Post.new(uri, {'Content-Type' =>'application/json'})
      req.body = stats.to_json

      response = Net::HTTP.new(uri.hostname, uri.port).request(req)
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

  end
end
