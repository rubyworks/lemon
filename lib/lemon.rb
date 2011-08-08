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

# Ruby Test standard location for test objects.
$TEST_SUITE ||= []

require 'lemon/test_class'

module Lemon

  # Lemon's toplevel test domain specific language.
  module DSL

    # Require script and record it.
    #
    # @param [STRING] script
    #   The load path of a script.
    #
    def covers(script)
      # TODO: record coverage list
      require script
    end
    alias :Covers :covers

    # Define a class/module test case.
    #
    # @param [Module,Class] target
    #   The class or module the tests will target.
    #
    # @yield
    #   Scope in which to define unit/method testcases.
    #
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
