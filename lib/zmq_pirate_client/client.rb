require 'ffi-rzmq'

module ZMQPirateClient
  class ClientError < StandardError; end
  class ConnectionTimeout < ClientError; end
  class SendError < ClientError; end
  class ParseError < ClientError; end

  class Response
    attr_reader :body

    def initialize(raw_data)
      # Could be a good idea to use a binary format here.
      @body = JSON.parse(raw_data)
    rescue JSON::ParserError
      raise ParseError
    end
  end

  class Client
    def initialize(options)
      options = { host: '0.0.0.0', port: 5567, retries: 2, timeout: 30 }.merge(options)
      @address = "tcp://#{options[:host]}:#{options[:port]}"
      @retries = options[:retries]
      @timeout = options[:timeout]
      @ctx = ZMQ::Context.new
      @poller = ZMQ::Poller.new

      at_exit { close_socket if @connected }
    end

    def send_message!(message)
      connect_socket unless @connected
      # `send_string` method queues the message and the zmq sends the message.
      if @socket.send_string(message) >= 0
        listen_for_reply
      else
        close_socket
        fail SendError
      end
    end

    def send_message(message)
      send_message!(message)
    rescue ClientError
      nil
    end

    private

    def listen_for_reply
      @retries.times do
        next unless @poller.poll(@timeout) > 0
        raw_data = ''
        @socket.recv_string(raw_data)
        return Response.new(raw_data)
      end
      close_socket
      fail ConnectionTimeout
    end

    def close_socket
      @poller.deregister(@socket, ZMQ::POLLIN)
      @socket.close
      @connected = false
    end

    def connect_socket
      @socket = @ctx.socket(ZMQ::REQ)
      # http://api.zeromq.org/2-1:zmq-setsockopt:
      # The value of 0 specifies no linger period.
      # Pending messages shall be discarded immediately when the socket is closed with zmq_close().
      @socket.setsockopt(ZMQ::LINGER, 0)
      @socket.connect(@address)

      @poller.register(@socket, ZMQ::POLLIN)
      @connected = true
    end
  end
end
