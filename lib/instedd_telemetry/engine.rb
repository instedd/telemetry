module InsteddTelemetry
  class Engine < ::Rails::Engine
    isolate_namespace InsteddTelemetry

    initializer "instedd_telemetry.start_agent" do |app|
      InsteddTelemetry::Agent.new.auto_start
    end

    initializer 'instedd_telemetry.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper InsteddTelemetry::WarningHelper
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end
  end
end
