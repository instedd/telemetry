require 'spec_helper'

describe InsteddTelemetry::ApiServer do
  let(:server) { InsteddTelemetry::ApiServer.new }

  it "starts a server" do
    server = double('server')
    allow(ApiServer).to receive(:new).and_return(server)
    expect(server).to receive(:run)

    ApiServer.start
  end

  it "parses commands" do
    expect(InsteddTelemetry).to receive(:add_counter).with(1, "2")

    message = {
      command: "add_counter",
      arguments: [1, "2"]
    }

    server.parse_command(message.to_json)
  end
end
