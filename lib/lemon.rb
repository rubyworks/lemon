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

$TEST_SUITE ||= []

require 'lemon/test_class'

module Lemon

  module DSL

    def covers(script)
      #TODO: record coverage list
      require script
    end
    alias :Covers :covers

    # Define a class/module test case.
    def test_case(target, &block)
      case target
      when Class
        $TEST_SUITE << Lemon::TestClass.new(:target=>target, &block)
      when Module
        $TEST_SUITE << Lemon::TestModule.new(:target=>target, &block)
      else
        if defined?(super)
          super(target, &block)
        else
          raise
        end
      end
    end

    alias :TestCase :test_case
    alias :testcase :test_case

  end

end

extend Lemon::DSL
