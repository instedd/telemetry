require 'spec_helper'

describe InsteddTelemetry::Api do
  let(:api) { InsteddTelemetry::Api.new('http://telemetry-test.instedd.org')}
  let(:uuid) { '1234-5678-0000' }

  before(:each) do
    allow(InsteddTelemetry).to receive(:instance_id).and_return(uuid)
  end

  it 'creates events' do
    event = {counters: [1,2,3], sets: ['a', 'b', 'c']}

    stub = stub_request(:post, "http://telemetry-test.instedd.org/api/v1/installations/#{uuid}/events")
      .with(body: event.to_json, :headers => {'Content-Type'=>'application/json'})
      .to_return(status: 200)

    api.create_event(event)

    expect(stub).to have_been_requested
  end

  it 'updates the installation' do
    installation = {application: 'verboice', admin_email: 'foo@bar.com'}

    stub = stub_request(:put, "http://telemetry-test.instedd.org/api/v1/installations/#{uuid}")
      .with(body: installation.to_json, :headers => {'Content-Type'=>'application/json'})
      .to_return(status: 200)

    api.update_installation(installation)

    expect(stub).to have_been_requested
  end
end
