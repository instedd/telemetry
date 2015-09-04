RSpec.configure do |config|
  config.before :each do
    Setting.clear_cache
  end
end
