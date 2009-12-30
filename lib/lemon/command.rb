#!/usr/bin/env ruby

require 'lemon'
require 'lemon/coverage'
require 'optparse'
require 'yaml'

module Lemon

  # Lemon Command-line tool.
  class Command

    # Initialize and run.
    def self.run
      new.run
    end

    attr_accessor :command
    attr_accessor :requires
    attr_accessor :includes
    attr_accessor :public_only

    def initialize
      @requires = []
      @includes = []
      @public_only = false
    end

    def parser
      @parser ||= OptionParser.new do |opt|
        opt.on('--coverage', '-c') do
          self.command = :coverage
        end
        opt.on('--generate', '-g') do
          self.command = :generate
        end
        opt.on('--public', '-p', "only include public methods") do
          self.public_only = true
        end
        opt.on("-I [PATH]" , 'include in $LOAD_PATH') do |path|
          self.includes = path
        end
        opt.on("-r [FILES]" , 'scripts to require') do |files|
          self.requires = files
        end
        opt.on_tail('--help', '-h', 'show this help message') do
          puts opt
          exit
        end
      end
    end

    #
    def public_only?
      @public_only
    end

    #
    def requires=(paths)
      @requires = paths.split(/[:;]/)
    end

    #
    def includes=(paths)
      @includes = paths.split(/[:;]/)
    end

    #
    def run
      parser.parse!

      includes.each do |path|
        $LOAD_PATHS.unshift(path)
      end

      tests = ARGV

      case command
      when :coverage
        coverage(tests)
      when :generate
        generate(tests)
      else
        test(tests)
      end
    end

    # Check test coverage.
    def coverage(tests)
      cover  = Lemon::Coverage.new(requires, :public => public_only?)
      suite  = Lemon::Test::Suite.new(tests)
      puts cover.coverage(suite).to_yaml
    end

    # Generate test skeletons.
    def generate(tests)
      cover  = Lemon::Coverage.new(requires, :public => public_only?)
      #suite  = Lemon::Test::Suite.new(tests)
      puts cover.generate #(suite).to_yaml
    end

    # Run unit tests.
    def test(tests)
      requires.each{ |path| require(path) }
      suite  = Lemon::Test::Suite.new(tests)
      runner = Lemon::Runner.new(suite)
      runner.run
    end

  end

end
