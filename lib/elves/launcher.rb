# frozen_string_literal: true

module Elves
  class Launcher
    def initialize(conf)
      @runner = Elves::Runner.new(conf)
    end

    def run
      @runner.run
    end
  end
end