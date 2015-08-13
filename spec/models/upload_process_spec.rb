require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::UploadProcess do

  describe "stats building" do

    it "builds counters and sets" do
      InsteddTelemetry.counter_add(:calls, {project: 1}, 2)
      InsteddTelemetry.counter_add(:calls, {project: 1})
      InsteddTelemetry.set_add(:channels, {project: 1}, :smpp)
      InsteddTelemetry.set_add(:channels, {project: 1}, :other)

      stats = UploadProcess.new(Period.last).stats
      expect(stats).to eq({
        "counters" => [
          { "type" => "calls", "key" => { "project" => 1 }, "value" => 3 }
        ],
        "sets" => [
          { "type" => "channels", "key" => { "project" => 1 }, "elements" => ["smpp", "other"] }
        ]
      })
    end

    it "separates by type" do
      InsteddTelemetry.counter_add(:calls, {project: 1})
      InsteddTelemetry.counter_add(:successful_calls, {project: 1}, 3)

      InsteddTelemetry.set_add(:channels, {project: 1}, :smpp)
      InsteddTelemetry.set_add(:users, {project: 1}, :foo)
      InsteddTelemetry.set_add(:users, {project: 1}, :bar)

      stats = UploadProcess.new(Period.last).stats
      expect(stats).to eq({
        "counters" => [
          {
            "type" => "calls",
            "key" => { "project" => 1 },
            "value" => 1
          },
          {
            "type" => "successful_calls",
            "key" => { "project" => 1 },
            "value" => 3
          }
        ],
        "sets" => [
          {
            "type" => "channels",
            "key" => { "project" => 1 },
            "elements" => ["smpp"]
          },
          {
            "type" => "users",
            "key" => { "project" => 1 },
            "elements" => ["foo", "bar"]
          }
        ]
      })
    end

    it "separates by key" do
      InsteddTelemetry.counter_add(:calls, {project: 1}, 20)
      InsteddTelemetry.counter_add(:calls, {project: 2}, 50)
      InsteddTelemetry.counter_add(:successful_calls, {project: 1}, 10)
      InsteddTelemetry.counter_add(:successful_calls, {project: 2}, 25)

      InsteddTelemetry.set_add(:channels, {project: 1}, :smpp)
      InsteddTelemetry.set_add(:channels, {project: 2}, :other)
      InsteddTelemetry.set_add(:users, {project: 1}, :foo)
      InsteddTelemetry.set_add(:users, {project: 2}, :bar)

      stats = UploadProcess.new(Period.last).stats

      expect(stats).to eq({
        "counters" => [
          {
            "type" => "calls",
            "key" => { "project" => 1 },
            "value" => 20
          },
          {
            "type" => "calls",
            "key" => { "project" => 2 },
            "value" => 50
          },
          {
            "type" => "successful_calls",
            "key" => { "project" => 1 },
            "value" => 10
          },
          {
            "type" => "successful_calls",
            "key" => { "project" => 2 },
            "value" => 25
          }
        ],
        "sets" => [
          {
            "type" => "channels",
            "key" => { "project" => 1 },
            "elements" => ["smpp"]
          },
          {
            "type" => "channels",
            "key" => { "project" => 2 },
            "elements" => ["other"]
          },
          {
            "type" => "users",
            "key" => { "project" => 1 },
            "elements" => ["foo"]
          },
          {
            "type" => "users",
            "key" => { "project" => 2 },
            "elements" => ["bar"]
          }
        ]
      })
    end

  end

end