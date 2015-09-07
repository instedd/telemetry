RSpec.configure do |config|
  config.before :each do
    InsteddTelemetry::Setting.clear_cache
  end
end
