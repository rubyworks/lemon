#!/usr/bin/env ruby

require 'lemon'
#require 'lemon/coverage'
require 'optparse'
require 'yaml'

module Lemon

  # Lemon Command-line tool.
  class Command

    def self.options
      raise "not implemented"
    end

    #
    def self.commands
      @commands ||= []
    end

    #
    def self.inherited(command_class)
      commands << command_class
    end

    # Initialize and run.
    def self.run
      cmd = commands.find do |command_class|
        [command_class.options].flatten.find do |opt|
          ARGV.delete(opt)
        end
      end
      cmd ? cmd.run : Commands::Test.run
    end
 
    #    Commands::Coverage.run
    #  elsif ARGV.delete("-g") || ARGV.delete("--generate")
    #    Commands::Generate.run
    #  else
    #    Commands::Test.run
    #  end
    #end

=begin
    # Check test coverage.
    def coverage(tests)
      cover  = Lemon::Coverage.new(requires, namespaces, :public => public_only?)
      suite  = Lemon::Test::Suite.new(tests)
      puts cover.coverage(suite).to_yaml
    end

    # Generate test skeletons.
    def generate(files)
      requires.each{ |path| require(path) }
      cover  = Lemon::Coverage.new(files, namespaces, :public => public_only?)
      #suite  = Lemon::Test::Suite.new(tests)
      puts cover.generate #(suite).to_yaml
    end

    # Run unit tests.
    def test(tests)
      requires.each{ |path| require(path) }
      suite  = Lemon::Test::Suite.new(tests)
      runner = Lemon::Runner.new(suite, format)
      runner.run
    end
=end

  end

end

require 'lemon/commands/test'
require 'lemon/commands/coverage'
require 'lemon/commands/generate'

