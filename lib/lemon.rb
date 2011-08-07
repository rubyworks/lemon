module Lemon

  # Access to metadata.
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/lemon.yml'))
    )
  end

  # Access to project metadata as constants.
  def self.const_missing(name)
    key = name.to_s.downcase
    metadata[key] || super(name)
  end

end

require 'citron'
require 'lemon/test_class'

module Lemon

  module DSL

    def covers(script)
      #TODO: record coverage list
      require script
    end
    alias :Covers :covers

    # Define a module test case.
    def test_module(target, &block)
      $TEST_SUITE << Lemon::TestModule.new(target, &block)
    end
    alias :TestModule :test_module

    # Define a class test case.
    def test_class(target, &block)
      raise unless Class === target
      $TEST_SUITE << Lemon::TestModule.new(target, &block)
    end
    alias :TestClass :test_class

  end

end

extend Lemon::DSL

