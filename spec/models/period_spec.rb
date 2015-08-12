require 'spec_helper'

describe InsteddTelemetry::Period do

  describe "obtaining current period" do

    it "creates new record if there isn't any" do
      now = Date.new(2015, 01, 01)
      Timecop.freeze(now)
      
      current_period = InsteddTelemetry::Period.current
      expect(InsteddTelemetry::Period.count).to eq(1)
      
      expect(current_period.beginning).to eq(now)
      expect(current_period.end).to eq(now + InsteddTelemetry::Period.span)
    end

    it "returns pre existing period if it hasn't finished" do
      d0 = Date.new(2015, 01, 01)
      
      Timecop.freeze(d0)
      p1 = InsteddTelemetry::Period.current

      Timecop.travel(d0 + InsteddTelemetry::Period.span - 1.day)
      p2 = InsteddTelemetry::Period.current

      expect(InsteddTelemetry::Period.count).to eq(1)
      expect(p2).to eq(p1)
      expect(p2.beginning).to eq(d0)
      expect(p2.end).to eq(d0 + InsteddTelemetry::Period.span)
    end

    it "creates new record if immediate last period has finished" do
      d0 = Date.new(2015, 01, 01)
      
      Timecop.freeze(d0)
      p1 = InsteddTelemetry::Period.current

      Timecop.travel(d0 + InsteddTelemetry::Period.span)
      p2 = InsteddTelemetry::Period.current

      expect(InsteddTelemetry::Period.count).to eq(2)
    end

    it "creates new record if non-immediate last period has finished" do
      d0 = Date.new(2015, 01, 01)
      d1 = d0 +  InsteddTelemetry::Period.span + InsteddTelemetry::Period.span
      
      Timecop.freeze(d0)
      p1 = InsteddTelemetry::Period.current

      Timecop.freeze(d1)
      p2 = InsteddTelemetry::Period.current

      expect(InsteddTelemetry::Period.count).to eq(2)
      expect(p2.beginning).to eq(d1)
      expect(p2.end).to eq(d1 + InsteddTelemetry::Period.span)
    end

  end


end