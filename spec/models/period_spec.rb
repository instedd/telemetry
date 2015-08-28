require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::Period do

  describe "obtaining current period" do

    it "creates new record if there isn't any" do
      now = Date.new(2015, 01, 01)
      Timecop.freeze(now)
      
      current_period = Period.current
      expect(Period.count).to eq(1)
      
      expect(current_period.beginning).to eq(now)
      expect(current_period.end).to eq(now + Period.span)
    end

    it "returns pre existing period if it hasn't finished" do
      d0 = Date.new(2015, 01, 01)
      
      Timecop.freeze(d0)
      p1 = Period.current

      Timecop.travel(d0 + Period.span - 1.day)
      p2 = Period.current

      expect(Period.count).to eq(1)
      expect(p2).to eq(p1)
      expect(p2.beginning).to eq(d0)
      expect(p2.end).to eq(d0 + Period.span)
    end

    it "creates new record if immediate last period has finished" do
      d0 = Date.new(2015, 01, 01)
      
      Timecop.freeze(d0)
      p1 = Period.current

      Timecop.travel(d0 + Period.span)
      p2 = Period.current

      expect(Period.count).to eq(2)
    end

    it "creates new record if non-immediate last period has finished" do
      d0 = Date.new(2015, 01, 01)
      d1 = d0 +  Period.span + Period.span
      
      Timecop.freeze(d0)
      p1 = Period.current

      Timecop.freeze(d1)
      p2 = Period.current

      expect(Period.count).to eq(2)
      expect(p2.beginning).to eq(d1)
      expect(p2.end).to eq(d1 + Period.span)
    end

  end

  describe "periods to upload" do

    before(:each) do
      d0 = DateTime.new(2014, 01, 01, 12, 0, 0)
      d1 = d0 + 1.day
      d2 = d1 + 1.day
      Timecop.freeze(d2 + 1.day)

      Period.create({beginning: d0, end: d1, stats_sent_at: d1})
      @period_to_upload = Period.create({beginning: d1, end: d2, stats_sent_at: nil})
      Period.create({beginning: d2, end: nil, stats_sent_at: nil})
    end

    it "sends finished periods that where not previously sent" do
      Period.lock_for_upload do |periods|
        expect(periods).to eq([@period_to_upload])
      end
    end

    it "places a lock on periods to upload" do
      Period.lock_for_upload do |periods|
        @period_to_upload.reload
        
        expect(@period_to_upload.lock_owner).not_to be_nil
        expect(@period_to_upload.lock_expiration).not_to be_nil
        expect(@period_to_upload.lock_expiration).to eq(DateTime.now + 15.minutes)
      end
    end

    it "releases locks after processing periods" do
      Period.lock_for_upload { |periods| }
      expect(Period.all.all? {|p| p.lock_owner.nil?}).to be_truthy
    end

    it "sends finished periods with expired locks that are not marked as sent" do
      p = Period.create({
        beginning: DateTime.now - 2.days,
        end: DateTime.now - 1.day,
        stats_sent_at: nil,
        
        lock_owner: "other_process",
        lock_expiration: DateTime.now - 1.minute
      })

      Period.lock_for_upload do |periods|
        p.reload

        expect(periods).to include(p)
        expect(p.lock_owner).to be_present
        expect(p.lock_owner).not_to eq("other_process")
        expect(p.lock_expiration).to eq(DateTime.now + 15.minutes)
      end
    end

  end

end