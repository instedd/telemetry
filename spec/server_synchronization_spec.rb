require 'spec_helper'
include InsteddTelemetry
include InsteddTelemetry::ServerSynchronization

describe InsteddTelemetry::ServerSynchronization do

  before(:each) do
    stub_request(:put, /api\/v1\/installations\/.*/).to_return(status: 200)
    stub_request(:post, /api\/v1\/installations\/.*\/events/).to_return(status: 200)
  end

  it "creates current period it doesn't exist" do
    d0 = Date.new(2015, 01, 01)
    Timecop.freeze(d0)
    
    ServerSynchronization.run_once

    expect(Period.count).to eq(1)
    expect(Period.last.beginning).to eq(d0)
  end

  it "creates intermediate periods between last one and current time" do
    d0 = Date.new(2015, 01, 01)
    d1 = d0 + Period.span + Period.span

    Timecop.freeze(d0)
    ServerSynchronization.run_once
    expect(Period.count).to eq(1)

    Timecop.travel(d1)
    ServerSynchronization.run_once
    expect(Period.count).to eq(3)

    expect(WebMock).to have_requested(:post, /api\/v1\/installations\/.*\/events/).twice

    periods = Period.order(:beginning)

    expect(periods[0].beginning).to eq(d0)
    expect(periods[0].end).to eq(d0 + Period.span)
    expect(periods[0].stats_sent_at).not_to be_nil

    expect(periods[1].beginning).to eq(periods[0].end)
    expect(periods[1].end).to eq(periods[1].beginning + Period.span)
    expect(periods[1].stats_sent_at).not_to be_nil

    expect(periods[2].beginning).to eq(periods[1].end)
    expect(periods[2].end).to eq(periods[2].beginning + Period.span)
    expect(periods[2].stats_sent_at).to be_nil
  end

end