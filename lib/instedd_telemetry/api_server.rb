require 'socket'

module InsteddTelemetry
  class ApiServer
    def self.start
      self.new.run
    end

    def run
      init_socket

      until should_stop? do
        Thread.start(@socket.accept) do |client, client_sockaddr|
          handle(client)
        end
      end
    end

    def handle(client)
      ActiveRecord::Base.connection_pool.with_connection do
        while (line = client.readline)
          begin
            parse_command line.chomp
          rescue Exception => e
            InsteddTelemetry::Logging.log_exception e, "Couldn't parse remote command: #{line}"
          end
        end
        client.close
      end
    end

    def parse_command(line)
      json = JSON.parse(line)
      InsteddTelemetry.send(json['command'], *json['arguments'])
    end

    def stop
      @should_stop = true
      @socket.close
    end

    private

    def should_stop?
      @should_stop
    end

    def init_socket
      @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM, 0
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)

      sockaddr = Socket.pack_sockaddr_in(InsteddTelemetry.configuration.api_port, '0.0.0.0')
      @socket.bind(sockaddr)
      @socket.listen(40)

      @should_stop = false
    end
  end
end
