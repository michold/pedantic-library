# frozen_string_literal: true

module Cli
  class Approval
    def self.get(message)
      puts "This script will #{message}"
      puts "Do you want to continue? (y/n)"
      gets.chomp == "y"
    end
  end
end
