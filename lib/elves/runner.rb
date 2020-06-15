# frozen_string_literal: true

module Elves
  class Runner
    attr_reader :config

    def initialize(conf)
      @config = conf
    end

    def run
      @server = server = start_server

      puts 'Use Ctrl-C to stop'

      server.run.each(&:join)

    rescue Interrupt
      # Swallow it
    end

    def start_server
      server = Elves::Server.new(self)
    end
  end
end