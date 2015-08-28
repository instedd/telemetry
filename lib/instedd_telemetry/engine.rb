module InsteddTelemetry
  class Engine < ::Rails::Engine
    isolate_namespace InsteddTelemetry

    initializer "instedd_telemetry.start_agent" do |app|
      InsteddTelemetry::Agent.new.auto_start
    end

    initializer "instedd_telemetry.initialize_instance_guid" do |app|
      InsteddTelemetry::Setting.find_or_create_by(key: :installation_id) do |guid_setting|
        guid_setting.value = SecureRandom.uuid
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end
  end
end
