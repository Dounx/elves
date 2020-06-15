# frozen_string_literal: true

module Elves
  class Server
    def initialize(runner)
      @runner = runner
      @config = runner.config
      @threads = []
      @sockets = []
      @status = :stop
      @selector = NIO::Selector.new
    end

    def run
      @status = :run

      config = @runner.config
      @server = TCPServer.new(config[:host], config[:port])
      monitor = @selector.register(@server, :r)
      monitor.value = proc { accept }
      puts "Listening to #{config[:host]}:#{config[:port]}"

      background('handle_servers') do
        handle_servers
      end
    end

    def handle_servers
      while @status == :run
        @selector.select do |monitor|
          monitor.value.call
        end
      end
    end

    def accept
      socket = @server.accept_nonblock
      @sockets << socket
      puts "Socket #{socket} connected"
      monitor = @selector.register(socket, :r)
      monitor.value = proc { read(socket) }
    end

    def read(socket)
      package = Package.new(socket)
      package.read.each do |payload|
        puts "Got #{payload}"
      end
    rescue EOFError
      puts "Socket #{socket} disconnected"
      @sockets.delete(socket)
      @selector.deregister(socket)
      socket.close
    end

    def background(name = nil)
      return unless block_given?

      thread = Thread.new { yield }
      thread.name = name
      @threads << thread
    end
  end
end