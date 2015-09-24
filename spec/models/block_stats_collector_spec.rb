require 'spec_helper'
include InsteddTelemetry
include InsteddTelemetry::StatCollectors

describe BlockCollector do

  it "runs block to obtain stats" do
    stats = {
      "counters" => [
        { "metric" => "calls", "key" => { "project" => 1 }, "value" => 3 }
      ],
      "sets" => [
        { "metric" => "channels", "key" => { "project" => 1 }, "elements" => ["smpp", "other"] }
      ]
    }

    collector = BlockCollector.new { |period| stats }

    expect(collector.collect_stats(Period.last)).to eq(stats)
  end

end
