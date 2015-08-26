module InsteddTelemetry
  class Configuration

    attr_accessor :server_url

    def initialize
      @server_url = "http://instedd.org/telemetry"
      @disabled   = false
    end

  end
end
