module InsteddTelemetry::StatCollectors

  class BlockCollector

    def initialize(&block)
      @block = block
    end

    def collect_stats(period)
      @block.call(period)
    end

  end

end