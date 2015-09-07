require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::PeriodUpload do

  describe "validations" do

    it "cannot be built without period" do
      expect{ PeriodUpload.new(nil) }.to raise_error("Undefined period")
    end

    it "cannot be built for unfinished periods" do
      Timecop.freeze

      expect{ PeriodUpload.new(InsteddTelemetry::Period.current) }.to raise_error("Period hasn't finished yet")
    end

  end


  describe "stats format" do

    let(:period)            { Period.last }
    let(:period_date_range) { { "beginning" => period.beginning.iso8601, "end" => period.end.iso8601 } }

    def last_period_stats
      Timecop.freeze(period.end + 1.day)
      PeriodUpload.new(period).stats
    end

    it "builds counters and sets" do
      InsteddTelemetry.counter_add(:calls, {project: 1}, 2)
      InsteddTelemetry.counter_add(:calls, {project: 1})
      InsteddTelemetry.set_add(:channels, {project: 1}, :smpp)
      InsteddTelemetry.set_add(:channels, {project: 1}, :other)

      expect(last_period_stats).to eq({
        "period" => period_date_range,
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
        "period" => period_date_range,
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
        "period" => period_date_range,
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

  describe "custom pull stats" do

    it "allows to add additional sets and counters before uploding" do
      period = Period.current
      Timecop.travel(1.week)

      pull_stats = {
        "counters" => [
          { "type" => "calls", "key" => { "project" => 1 }, "value" => 3 }
        ],
        "sets" => [
          { "type" => "channels", "key" => { "project" => 1 }, "elements" => ["smpp", "other"] }
        ]
      }

      upload = PeriodUpload.new(period)
      upload.collect_pull_stats_with [
        StatCollectors::BlockCollector.new { |p| pull_stats }
      ]

      expect(upload.stats["counters"]).to eq(pull_stats["counters"])
      expect(upload.stats["sets"]).to eq(pull_stats["sets"])
    end

    it "merges pull and push stats" do
      InsteddTelemetry.counter_add(:calls, {project: 1}, 20)
      InsteddTelemetry.counter_add(:calls, {project: 1}, 50)

      pull_stats = {
        "counters" => [
          { "type" => "calls", "key" => { "project" => 2 }, "value" => 3 }
        ]
      }

      period = Period.current
      Timecop.travel(1.week)

      upload = PeriodUpload.new(period)
      upload.collect_pull_stats_with [
        StatCollectors::BlockCollector.new { |p| pull_stats }
      ]

      counters = upload.stats["counters"]

      expect(counters.length).to eq(2)
      expect(counters[0]).to eq({"type"=>"calls", "key"=>{"project"=>1}, "value"=>70})
      expect(counters[1]).to eq({"type"=>"calls", "key"=>{"project"=>2}, "value"=>3})
    end

  end

  describe "stats upload" do
    let(:api) { double('api') }
    let(:response) {double('response', code: '200')}

    before(:each) do
      allow(InsteddTelemetry).to receive(:api).and_return(api)

      InsteddTelemetry.counter_add(:calls, {project: 1})
      Timecop.travel(Period.last.end + 1.day)
    end

    let(:process)    { PeriodUpload.new(Period.last) }

    it "sends stats to the server" do
      stats = double('stats')
      expect(process).to receive(:stats).and_return(stats)
      expect(api).to receive(:create_event).with(stats).and_return(response)

      process.run
    end

    it "marks period as already reported" do
      allow(api).to receive(:create_event).and_return(response)

      process.run

      expect(Period.last.stats_sent_at.to_i).to eq(Time.now.to_i)
    end

    it "doesn't send anything for repeated runs over already sent period" do
      expect(api).to receive(:create_event).and_return(response).once

      process.run
      process.run
    end

    it "doesn't mark period as reported if upload request failed" do
      failed_response = double('response', code: '400')
      expect(api).to receive(:create_event).and_return(failed_response)

      process.run

      expect(Period.last.stats_already_sent?).to be(false)
    end

  end

end
