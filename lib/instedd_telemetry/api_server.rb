require 'socket'

module InsteddTelemetry
  class ApiServer
    def initialize
      @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM, 0
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)
      sockaddr = Socket.pack_sockaddr_in(InsteddTelemetry.configuration.api_port, '0.0.0.0')
      @socket.bind(sockaddr)
      @socket.listen(40)
      @should_stop = false
    end

    def run
      loop do
        break if @should_stop
        Thread.start(@socket.accept) do |client, client_sockaddr|
          while (line = client.readline.chomp)
            begin
              parse_command line
            rescue Exception => e
              InsteddTelemetry::Logging.log_exception e, "Couldn't parse remote command: #{line}"
            end
          end
          client.close
        end
      end
    end

    def stop
      @should_stop = true
      @socket.close
    end

    def parse_command(line)
      json = JSON.parse(line)
      InsteddTelemetry.send(json['command'], *json['arguments'])
    end

    def self.start
      self.new.run
    end
  end
end
