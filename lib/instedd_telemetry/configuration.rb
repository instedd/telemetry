module InsteddTelemetry
  class Configuration

    DEFAULT_SERVER_URL = "http://instedd.org/telemetry"
    DEFAULT_API_PORT = 8089

    attr_accessor :server_url
    attr_accessor :api_port
    attr_accessor :application
    attr_reader :collectors

    def initialize
      @server_url = DEFAULT_SERVER_URL
      @api_port = DEFAULT_API_PORT
      @application = Rails.application.class.parent_name.downcase
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
