require 'spec_helper'
include InsteddTelemetry
include InsteddTelemetry::Tracking

describe InsteddTelemetry::Tracking do

  describe "sets" do

    it "creates set occurrences on set_add for each distinct key attribute set" do
      expect{
        set_add(:channels, {project_id: 1}, :smpp)
        set_add(:channels, {project_id: 2}, :smpp)
      }.to change(SetOccurrence, :count).by(2)
    end

    it "exposes parsed key attributes after retrieving from database" do
      set_add(:channels, {project_id: 3}, :smpp)
      occurrence = SetOccurrence.first
      expect(occurrence.parse_key_attributes).to eq({"project_id" => 3})
    end

    it "does not create new occurrence if element was present" do
      set_add(:channels, {project_id: 3}, :smpp)

      expect{
        set_add(:channels, {project_id: 3}, :smpp)
      }.not_to change(SetOccurrence, :count)
    end

    it "uses normalized attributes to identify set keys" do
      set_add(:channels, {project_id: 3, other_attribute: :ok}, :smpp)

      expect{
        set_add(:channels, {other_attribute: :ok, project_id: 3}, :smpp)
        set_add(:channels, {"project_id" => 3, "other_attribute" => :ok}, :smpp)
        set_add(:channels, {project_id: 3, other_attribute: "ok"}, :smpp)
      }.not_to change(SetOccurrence, :count)
    end

    it "creates new occurrences when new element is added to pre-existing key" do
      set_add(:channels, {project_id: 3}, :smpp)
      set_add(:channels, {project_id: 3}, :other)

      expect(SetOccurrence.count).to eq(2)
    end

  end

  describe "counters" do

    it "stores counter after first add" do
      expect{
        counter_add(:calls, {project_id: 1})
        counter_add(:calls, {project_id: 2})
      }.to change(Counter, :count).by(2)
    end

    it "initializes counters correctly" do
      counter_add(:calls, {project_id: 1})
      expect(Counter.first.count).to eq(1)
    end

    it "increments counters according to specified amount" do
      counter_add(:calls, {project_id: 1})
      counter_add(:calls, {project_id: 2})

      c1 = Counter.first
      c2 = Counter.last

      counter_add(:calls, {project_id: 1})

      expect(c1.reload.count).to eq(2)
      expect(c2.reload.count).to eq(1)

      counter_add(:calls, {project_id: 1}, 2)
      counter_add(:calls, {project_id: 2}, 10)

      expect(c1.reload.count).to eq(4)
      expect(c2.reload.count).to eq(11)
    end

  end

  describe "timespans" do

    it "stores timespan on first update" do
      expect {
        timespan_update(:user_lifespan, {user_id: 1}, Date.yesterday)
      }.to change(Timespan, :count).by(1)
    end

    it "initializes timespan correctly" do
      Timecop.freeze(Time.utc(2015, 1, 1, 12, 0, 0))
      timespan_update(:user_lifespan, {user_id: 1}, Date.yesterday)

      timespan = Timespan.first
      expect(timespan.since).to eq(Date.yesterday)
      expect(timespan.until).to be_within(1.second).of(Time.now)
    end

    it "updates lifespan if it already exists" do
      Timecop.freeze(Time.utc(2015, 1, 1, 12, 0, 0))

      start = Date.yesterday
      timespan_update(:user_lifespan, {user_id: 1}, start)

      Timecop.travel(1.day)

      expect {
        timespan_update(:user_lifespan, {user_id: 1}, start)
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
        timespan_since_creation_update(:user_lifespan, {user_id: 1}, FakeRecord.new)
      }.to change(Timespan, :count).by(1)

      timespan = Timespan.first
      expect(timespan.bucket).to eq("user_lifespan")
      expect(timespan.parse_key_attributes).to eq({"user_id" => 1})
      expect(timespan.since).to eq(Date.yesterday)
      expect(timespan.until).to be_within(1.second).of(Time.now)
    end

    # See https://github.com/instedd/telemetry_rails/issues/98
    # We had records in production with created_at = nil which caused invalid timespans to be saved
    it "ignores timespans with invalid dates" do
      expect {
        timespan_update(:user_lifespan, {user_id: 1}, nil)
      }.not_to change(Timespan, :count)
    end
  end

end
