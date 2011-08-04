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

require 'lemon/test_module'

module Test
  extend self

  #
  def covers(script)
    #TODO: record covers list somewhere
    require script
  end
  alias :Covers :covers

  # Define a class test.
  def class(target_class, &block)
    $TEST_SUITE << Lemon::TestModule.new(nil, :target=>target_class, &block)
  end
  alias :Class :class

  # Define a module test.
  def module(target_module, &block)
    $TEST_SUITE << Lemon::TestModule.new(nil, :target=>target_module, &block)
  end
  alias :Module :module
end


def self.Covers(*args, &block)
  Test.covers(*args, &block)
end

def self.TestClass(*args, &block)
  Test.class(*args, &block)
end

def self.TestModule(*args, &block)
  Test.module(*args, &block)
end
