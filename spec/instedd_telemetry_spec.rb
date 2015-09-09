require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry do

  it "provides access to tracking API" do
    expect{
      InsteddTelemetry.set_add(:channels, {project_id: 1}, :smpp)
    }.to change(SetOccurrence, :count).by(1)
  end

  it "initializes the first period when the first stat is recorded" do
   Timecop.freeze

   InsteddTelemetry.counter_add(:calls, {project_id: 1})

   counter = Counter.first

   expect(counter.period).to be_present
   expect(counter.period).to eq(Period.current)
  end

  describe "user settings" do

    it "uploads data by default" do
      expect(InsteddTelemetry.upload_enabled).to be_truthy
    end

    it "doesn't send data if user opts out" do
      Setting.set(:disable_upload, "true")
      expect(InsteddTelemetry.upload_enabled).to be_falsey
    end

  end

  describe "engine setup" do

    it "yields configuration object" do
      InsteddTelemetry.setup do |configuration|
        expect(configuration).to eq(InsteddTelemetry.configuration)
      end
    end

  end

  describe "configuration" do

    it "returns application name" do
      InsteddTelemetry.configuration.application = "an application name"

      expect(InsteddTelemetry.application).to eq("an application name")
    end
    
  end

end
