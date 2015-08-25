module InsteddTelemetry
  class Engine < ::Rails::Engine
    isolate_namespace InsteddTelemetry

    initializer "instedd_telemetry.start_agent" do |app|
      InsteddTelemetry::Agent.new.auto_start
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end
  end
end
