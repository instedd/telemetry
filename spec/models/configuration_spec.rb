require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::Configuration do

  let(:configuration) { Configuration.new }

  it "provides a default server_url" do
    expect(configuration.server_url).to eq(Configuration::DEFAULT_SERVER_URL)
  end

  it "provides a default application name" do
    expect(configuration.application).to eq(Rails.application.class.parent_name.downcase)
  end

  it "allows to change telemetry server configuration" do
    configuration.server_url = "http://example.com"
    expect(configuration.server_url).to eq("http://example.com")
  end

  it "allows to change application name configuration" do
    configuration.application = "my cool instedd app"
    expect(configuration.application).to eq("my cool instedd app")
  end

  it "allows to add custom collector by passing a block" do
    configuration.add_collector { |p| { "counters" => [] } }
    collectors = configuration.collectors

    expect(collectors.size).to eq(1)
    expect(collectors.first).to be_instance_of(InsteddTelemetry::StatCollectors::BlockCollector)
  end

  it "allows to add custom collector by passing an arbitrary object" do
    class CustomCollector
      def collect_stats
        # do somthing
      end
    end

    configuration.add_collector CustomCollector.new
    collectors = configuration.collectors

    expect(collectors.size).to eq(1)
    expect(collectors.first).to be_instance_of(CustomCollector)
  end

end
