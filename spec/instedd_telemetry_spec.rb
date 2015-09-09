require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry do

  describe "sets" do

    it "creates set occurrences on set_add for each distinct key attribute set" do
      expect{
        InsteddTelemetry.set_add(:channels, {project_id: 1}, :smpp)
        InsteddTelemetry.set_add(:channels, {project_id: 2}, :smpp)
      }.to change(SetOccurrence, :count).by(2)
    end

    it "exposes parsed key attributes after retrieving from database" do
      InsteddTelemetry.set_add(:channels, {project_id: 3}, :smpp)
      occurrence = SetOccurrence.first
      expect(occurrence.parse_key_attributes).to eq({"project_id" => 3})
    end

    it "does not create new occurrence if element was present" do
      InsteddTelemetry.set_add(:channels, {project_id: 3}, :smpp)

      expect{
        InsteddTelemetry.set_add(:channels, {project_id: 3}, :smpp)
      }.not_to change(SetOccurrence, :count)
    end

    it "uses normalized attributes to identify set keys" do
      InsteddTelemetry.set_add(:channels, {project_id: 3, other_attribute: :ok}, :smpp)

      expect{
        InsteddTelemetry.set_add(:channels, {other_attribute: :ok, project_id: 3}, :smpp)
        InsteddTelemetry.set_add(:channels, {"project_id" => 3, "other_attribute" => :ok}, :smpp)
        InsteddTelemetry.set_add(:channels, {project_id: 3, other_attribute: "ok"}, :smpp)
      }.not_to change(SetOccurrence, :count)
    end

    it "creates new occurrences when new element is added to pre-existing key" do
      InsteddTelemetry.set_add(:channels, {project_id: 3}, :smpp)
      InsteddTelemetry.set_add(:channels, {project_id: 3}, :other)

      expect(SetOccurrence.count).to eq(2)
    end

  end

  describe "counters" do

    it "stores counter after first add" do
      expect{
        InsteddTelemetry.counter_add(:calls, {project_id: 1})
        InsteddTelemetry.counter_add(:calls, {project_id: 2})
      }.to change(Counter, :count).by(2)
    end

    it "initializes counters correctly" do
      InsteddTelemetry.counter_add(:calls, {project_id: 1})
      expect(Counter.first.count).to eq(1)
    end

    it "increments counters according to specified amount" do
      InsteddTelemetry.counter_add(:calls, {project_id: 1})
      InsteddTelemetry.counter_add(:calls, {project_id: 2})

      c1 = Counter.first
      c2 = Counter.last

      InsteddTelemetry.counter_add(:calls, {project_id: 1})

      expect(c1.reload.count).to eq(2)
      expect(c2.reload.count).to eq(1)

      InsteddTelemetry.counter_add(:calls, {project_id: 1}, 2)
      InsteddTelemetry.counter_add(:calls, {project_id: 2}, 10)

      expect(c1.reload.count).to eq(4)
      expect(c2.reload.count).to eq(11)
    end

  end

  describe "timespans" do

    it "stores timespan on first update" do
      expect {
        InsteddTelemetry.timespan_update(:user_lifespan, {user_id: 1}, Date.yesterday)
      }.to change(Timespan, :count).by(1)
    end

    it "initializes timespan correctly" do
      Timecop.freeze(Time.utc(2015, 1, 1, 12, 0, 0))
      InsteddTelemetry.timespan_update(:user_lifespan, {user_id: 1}, Date.yesterday)

      timespan = Timespan.first
      expect(timespan.since).to eq(Date.yesterday)
      expect(timespan.until).to be_within(1.second).of(Time.now)
    end

    it "updates lifespan if it already exists" do
      Timecop.freeze(Time.utc(2015, 1, 1, 12, 0, 0))

      start = Date.yesterday
      InsteddTelemetry.timespan_update(:user_lifespan, {user_id: 1}, start)

      Timecop.travel(1.day)

      expect {
        InsteddTelemetry.timespan_update(:user_lifespan, {user_id: 1}, start)
      }.not_to change(Timespan, :count)

      timespan = Timespan.first
      expect(timespan.since).to eq(start)
      expect(timespan.until).to be_within(1.second).of(Time.now)
    end

    it "provides handy way to update span since record creation" do
      Timecop.freeze
      class FakeRecord
        def created_at
          Date.yesterday
        end
      end

      expect {
        InsteddTelemetry.timespan_since_creation_update(:user_lifespan, {user_id: 1}, FakeRecord.new)
      }.to change(Timespan, :count).by(1)

      timespan = Timespan.first
      expect(timespan.bucket).to eq("user_lifespan")
      expect(timespan.parse_key_attributes).to eq({"user_id" => 1})
      expect(timespan.since).to eq(Date.yesterday)
      expect(timespan.until).to be_within(1.second).of(Time.now)
    end

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
