require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::Setting do

  it "persists settings in database" do
    expect {
      Setting.set(:foo, :bar)
    }.to change(Setting, :count).by(1)

    expect(Setting.get(:foo)).to eq("bar")
  end

  it "updates existing setting if setting twice for same key" do
    Setting.set(:foo, :bar)

    expect {
      Setting.set(:foo, :baz)
    }.not_to change(Setting, :count)

    expect(Setting.get(:foo)).to eq("baz")
  end

  it "fails to create record if key already present" do
    Setting.set(:foo, :bar)

    expect {
      Setting.create(key: :foo, value: :baz)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "allows to get values parsed as boolean" do
    Setting.set(:foo, "true")
    Setting.set(:bar, "false")

    expect(Setting.get_bool(:foo)).to eq(true)
    expect(Setting.get_bool(:bar)).to eq(false)
    expect(Setting.get_bool(:baz)).to be_nil
  end

  it "allows setting multiple values at once" do
    Setting.set(:a, 1)
    Setting.set(:b, 2)
    Setting.set(:c, 3)

    Setting.set_all({
      a: 10,
      b: 20
    })

    expect(Setting.get(:a)).to eq("10")
    expect(Setting.get(:b)).to eq("20")
    expect(Setting.get(:c)).to eq("3")
  end

  it "caches settings" do
    Setting.set(:a, 1)
    Setting.get(:a)

    expect(Setting).not_to receive(:find_by_key).with(:a)
    expect(Setting.get(:a)).to eq("1")
  end

  it "clear cache when setting" do
    Setting.set(:a, 1)
    Setting.get(:a)
    Setting.set(:a, 2)

    expect(Setting).to receive(:find_by_key).with(:a).and_return(Setting.new(value: "2"))

    expect(Setting.get(:a)).to eq("2")
  end

  it "clear cache when setting all" do
    Setting.set(:a, 1)
    Setting.get(:a)
    Setting.set_all(a: 2, b:5)

    expect(Setting).to receive(:find_by_key).with(:a).and_return(Setting.new(value: "2"))

    expect(Setting.get(:a)).to eq("2")
  end

end
