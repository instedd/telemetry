require 'socket'

module InsteddTelemetry
  class ApiServer
    def self.start
      self.new.run
    end

    def run
      until try_init_socket do
          InsteddTelemetry::Logging.log :warn, "Could not start remote api server. Will retry in 1 minute."
          sleep 1.minute
      end

      InsteddTelemetry::Logging.log :info, "Remote api server successfully started on port #{InsteddTelemetry.configuration.api_port}"
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

    def try_init_socket
      begin
        init_socket
        true
      rescue
        false
      end
    end

    def init_socket
      @socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM, 0

      # allow other daemons to bind to this port if inactive (avoids "address already in use" issues after a recent crash)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      
      # if kernel supports it, allow multiple daemons to attach to the same port.
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true) if reuse_port?

      sockaddr = Socket.pack_sockaddr_in(InsteddTelemetry.configuration.api_port, '0.0.0.0')
      @socket.bind(sockaddr)
      @socket.listen(40)

      @should_stop = false
    end

    def reuse_port?
      Socket.constants.include? :SO_REUSEPORT
    end

  end
end
