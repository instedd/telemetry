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

  describe "socket" do
    let(:socket) { double('socket').as_null_object }
    let(:client) { double('client').as_null_object }

    before :each do
      allow(Socket).to receive(:new).and_return(socket)
    end

    it "receives a message" do
      expect(server).to receive(:parse_command).with('a remote command')

      expect(socket).to receive(:accept).and_return(client)

      expect(client).to receive(:readline).and_return("a remote command\n", nil)
      expect(client).to receive(:close)

      expect(server).to receive(:should_stop?).and_return(false, true)

      server.run
    end
  end
end
