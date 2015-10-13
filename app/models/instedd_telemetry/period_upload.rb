module InsteddTelemetry
  class PeriodUpload

    def initialize(period, pull_collectors = [])
      raise "Undefined period"           unless period.present?
      raise "Period hasn't finished yet" unless period.already_finished?

      @period = period
      @pull_collectors = pull_collectors
      @errors = []
      @stats = nil
    end

    def run
      post report and mark_period_as_sent unless @period.stats_already_sent?
    end

    def report
      build_stats
      
      report = {
        "period"  =>  { "beginning" => @period.beginning.iso8601, "end" => @period.end.iso8601 },
        "application" => InsteddTelemetry.application
      }

      report["errors"] = @errors if @errors.any?
      report.merge! @stats
    end

    def add_block_collector(&block)
      add_collector(StatCollectors::BlockCollector.new(&block))
    end

    def add_collector(collector)
      @pull_collectors.push collector
    end
    
    private

    def build_stats
      return @stats if @stats.present?

      @stats = pushed_stats_json
      @pull_collectors.each { |c| merge_collector_stats(c, @stats) }
    end

    def merge_collector_stats(collector, current_stats)
      begin
        collector_stats = collector.collect_stats(@period).with_indifferent_access

        current_stats["counters"].concat(collector_stats["counters"])   if collector_stats["counters"]
        current_stats["sets"].concat(collector_stats["sets"])           if collector_stats["sets"]
        current_stats["timespans"].concat(collector_stats["timespans"]) if collector_stats["timespans"]
      rescue Exception => e
        @errors.push format_exception(e)
      end
    end

    def post(stats)
      response = InsteddTelemetry.api.create_event(stats)
      return response.code == "200"
    end

    def pushed_stats_json
      ret = { "counters" => [], "sets" => [], "timespans" => [] }
      
      begin
        ret["counters"]  += counters_json
        ret["sets"]      += sets_json
        ret["timespans"] += timespans_json
      rescue Exception => e
        @errors.push format_exception(e)
      end

      ret
    end

    def counters_json
      counters = Counter.where(period_id: @period.id)
      counters.map do |c|
        {
          "metric" => c.bucket,
          "key" => c.parse_key_attributes,
          "value" => c.count
        }
      end
    end

    def sets_json
      sets = SetOccurrence.where(period_id: @period.id)
      sets.group_by{|occ| [occ.bucket, occ.parse_key_attributes]}.map do |key, occurrences|
        {
          "metric" => key[0],
          "key" => key[1],
          "elements" => occurrences.map(&:element)
        }
      end
    end

    def timespans_json
      timespans = Timespan.where(period_id: @period.id)
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

    def format_exception(e)
      "#{e.message}\n\t#{e.backtrace.join("\n\t")}"
    end

  end
end
