require 'spec_helper'

describe InsteddTelemetry do

  describe "sets" do

    it "creates set occurrences on set_add" do
      expect {
        InsteddTelemetry.set_add(:foo, :bar)
      }.to change(SetOccurrence, :count).by(1)
    end

    it "stores empty metadata by default" do
      InsteddTelemetry.set_add(:foo, :bar)
      occurrence = SetOccurrence.first!

      expect(occurrence.metadata).to be_empty
    end

    it "allows to retrieve saved metadata" do
      InsteddTelemetry.set_add(:foo, :bar, {"attr_1" => 123, "attr_2" => 456})
      occurrence = SetOccurrence.first!

      expect(occurrence.metadata).to eq({"attr_1" => 123, "attr_2" => 456})
    end

    it "does not create new occurrence if element was present" do
      InsteddTelemetry.set_add(:foo, :bar)

      expect{
        InsteddTelemetry.set_add(:foo, :bar)
      }.not_to change(SetOccurrence, :count)
    end

    it "merges metadata if element was already present in set" do
      InsteddTelemetry.set_add(:foo, :bar)
      
      InsteddTelemetry.set_add(:foo, :baz, {"attr_1" => 123, "attr_2" => 456})
      InsteddTelemetry.set_add(:foo, :baz, {"attr_2" => 111, "attr_3" => 789})

      occurrence = SetOccurrence.where(set_key: :foo, element_key: :bar).first
      expect(occurrence.metadata).to be_empty

      occurrence = SetOccurrence.where(set_key: :foo, element_key: :baz).first
      expect(occurrence.metadata).to eq({"attr_1" => 123, "attr_2" => 111, "attr_3" => 789})
    end

  end

end