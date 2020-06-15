# frozen_string_literal: true

require "json"

module Elves
  class Package
    MAX_LEN = 16384 # byte

    def initialize(socket)
      @socket = socket
    end

    def read
      payloads = @socket.read_nonblock(MAX_LEN)
      payloads.split('\0').map do |payload|
        JSON.parse(payload)
      end
    end

    def write(data)
      payload = JSON.dump(data)
      payload << '\0'
      @socket.write_nonblock(payload)
    end

    def close
      @socket.close
    end
  end
end