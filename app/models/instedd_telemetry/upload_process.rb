module InsteddTelemetry
  class UploadProcess

    def initialize(period)
      @period = period
    end

    def stats
      counters = Counter.where(period_id: @period.id)
      set_occurrences = SetOccurrence.where(period_id: @period.id)

      {
        "counters" => counters_json(counters),
        "sets" => sets_json(set_occurrences)
      }
    end

    def counters_json(counters)
      counters.map do |c|
        {
          "type" => c.bucket,
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
