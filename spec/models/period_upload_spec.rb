require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::PeriodUpload do

  let(:server_url) { "http://instedd.org/telemetry/" }

  describe "validations" do

    it "cannot be built without period or server url" do
      expect{ PeriodUpload.new(nil, server_url) }.to     raise_error("Undefined period")
      expect{ PeriodUpload.new(Period.current, nil) }.to raise_error("Undefined server URL")
    end

    it "cannot be built for unfinished periods" do
      Timecop.freeze

      expect{ PeriodUpload.new(Period.current, server_url) }.to raise_error("Period hasn't finished yet")
    end

  end


  describe "stats format" do

    def last_period_stats
      Timecop.freeze(Period.last.end + 1.day)
      PeriodUpload.new(Period.last, "http://example.com").stats
    end

    it "builds counters and sets" do
      InsteddTelemetry.counter_add(:calls, {project: 1}, 2)
      InsteddTelemetry.counter_add(:calls, {project: 1})
      InsteddTelemetry.set_add(:channels, {project: 1}, :smpp)
      InsteddTelemetry.set_add(:channels, {project: 1}, :other)

      expect(last_period_stats).to eq({
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

      expect(last_period_stats).to eq({
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


      expect(last_period_stats).to eq({
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

  describe "stats upload" do

    before(:each) do
      stub_request(:post, server_url).to_return(status: 200, headers: {})
      
      InsteddTelemetry.counter_add(:calls, {project: 1})
      Timecop.travel(Period.last.end + 1.day)
    end
    
    let(:server_request) do
      a_request(:post, server_url).with({
        body: process.stats.to_json,
        headers: {"Content-Type" => "application/json"}
      })
    end
    
    let(:process)    { PeriodUpload.new(Period.last, server_url) }

    it "sends stats to the server" do
      process.run

      expect(server_request).to have_been_made.once
    end

    it "marks period as already reported" do
      process.run
      
      expect(Period.last.stats_sent_at.to_i).to eq(Time.now.to_i)
    end

    it "doesn't send anything for repeated runs over already sent period" do
      process.run
      process.run
      
      expect(server_request).to have_been_made.once
    end

    it "doesn't mark period as reported if upload request failed" do
      stub_request(:post, server_url).to_return(status: 400, headers: {})
      process.run

      expect(Period.last.stats_already_sent?).to be(false)
    end

  end

end