module InsteddTelemetry
  class Configuration

    DEFAULT_SERVER_URL = "http://instedd.org/telemetry"
    DEFAULT_API_PORT = 8089
    DEFAULT_PERIOD_SIZE = 1.week
    DEFAULT_RUN_INTERVAL = 1.hour

    attr_accessor :server_url
    attr_accessor :api_port
    attr_accessor :application
    attr_reader   :collectors
    attr_accessor :period_size
    attr_accessor :process_run_interval

    def initialize
      @server_url = DEFAULT_SERVER_URL
      @api_port = DEFAULT_API_PORT
      @application = Rails.application.class.parent_name.downcase
      @disabled   = false
      @collectors = []
      @period_size = DEFAULT_PERIOD_SIZE
      @process_run_interval = DEFAULT_RUN_INTERVAL
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
