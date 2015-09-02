module InsteddTelemetry
  class Configuration

    DEFAULT_SERVER_URL = "http://instedd.org/telemetry"

    attr_accessor :server_url
    attr_reader :collectors

    def initialize
      @server_url = DEFAULT_SERVER_URL
      @disabled   = false
      @collectors = []
    end

    def add_collector(collector = nil, &block)
      if collector
        collectors << collector
      else
        collectors << InsteddTelemetry::StatCollectors::BlockCollector.new(&block)        
      end
    end

  end
end
