require 'lemon/model/pending'
require 'lemon/model/test_context'
require 'lemon/model/test_unit'

module Lemon

  # Test Case encapsulates a collection of 
  # unit tests organized into groups of contexts.
  class TestCase

    # The test suite to which this testcase belongs.
    attr :suite

    # A testcase +target+ is a class or module.
    attr :target

    # Description of the aspect of the test class/module
    # to be testd.
    attr :aspect

    # Ordered list of testunits.
    attr :units

    # Before matching test units.
    attr :before
    #attr_accessor :prepare

    # After matching test units.
    attr :after
    #attr_accessor :cleanup

    # Module for parsing test case scripts.
    attr :dsl

    # A test case +target+ is a class or module.
    def initialize(suite, target, aspect=nil, &block)
      @suite  = suite
      @target = target
      @aspect = aspect

      #@steps  = []
      @units  = []

      #@prepare = nil
      #@cleanup = nil

      @before = {}
      @after  = {}

      @dsl = DSL.new(self, &block)
    end

    # DEPRECATE
    alias_method :testunits, :units

    # Iterate over each test unit.
    def each(&block)
      units.each(&block)
    end

    #
    def size
      testunits.size
    end

    #
    def to_s
      target.to_s.sub(/^\#\<.*?\>::/, '')
    end

    #
    def prepare
      @before[[]]
    end

    #
    def cleanup
      @after[[]]
    end

    #
    class DSL < Module
      #
      def initialize(testcase, &casecode)
        @testcase = testcase
        @context  = nil #Instance.new(self)
        module_eval(&casecode)
      end

      # Define a unit test for this case.
      #
      # @example
      #   unit :puts => "print message with new line to stdout" do
      #     puts "Hello"
      #   end
      #
      def unit(*target, &block)
        target = target.map{ |x| Hash === x ? x.to_a : x }.flatten
        method, aspect = *target
        unit = TestUnit.new(
          @testcase, method,
          :function => false,
          :aspect   => aspect,
          :context  => @context,
          :caller   => caller,
          &block
        )
        #@testcase.steps << unit
        @testcase.units << unit
        unit
      end
      alias_method :TestUnit, :unit
      alias_method :testunit, :unit
      alias_method :Unit, :unit

      # Define a meta-method unit test for this case.
      def meta(*target, &block)
        target = target.map{ |x| Hash === x ? x.to_a : x }.flatten
        method, aspect = *target
        unit = TestUnit.new(
          @testcase, method,
          :function => true,
          :aspect   => aspect,
          :context  => @context,
          :caller   => caller,
          &block
        )
        #@testcase.steps << unit
        @testcase.units << unit
        unit
      end
      alias_method :MetaUnit, :meta
      alias_method :metaunit, :meta
      alias_method :Meta, :meta

      # Omit a unit from testing.
      #
      #  omit unit :foo do
      #    # ...
      #  end
      #
      def Omit(unit)
        unit.omit = true
      end
      alias_method :omit, :Omit

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def setup(description=nil, &procedure)
        if procedure
          context  = TestContext.new(@testcase, description, &procedure)
          @context = context
          #@function = false
          #@testcase.steps << context
        end
      end
      alias_method :Setup, :setup
      alias_method :Concern, :setup
      alias_method :concern, :setup

      # @deprecate This alias will probably not stick around.
      alias_method :Context, :setup
      alias_method :context, :setup

=begin
      # TODO: Currently there is no difference between Setup, Instance and Singleton

      ## Define a new test instance for this case.
      def instance(description=nil, &block)
        if block
          #context = TestInstance.new(@testcase, description, &block)
          context = TestContext.new(@testcase, description, &block)
        else
          context = TestContext.new(@testcase, description) do
                      @testcase.target.new  # No arguments!!!
                    end
        end
        @context = context
        #@function = false
        #@testcase.steps << context
      end
      alias_method :Instance, :instance

      # Define a new test singleton for this case.
      def Singleton(description=nil, &block)
        if block
          #context = TestSingleton.new(@testcase, description, &block)
          context = TestContext.new(@testcase, description, &block)
        else
          context = TestContext.new(@testcase, description){ @testcase.target }
        end
        @context = context
        #@function = true
        #@testcase.steps << context
      end
      alias_method :singleton, :Singleton
=end

      # Teardown procedure is used to clean-up after each unit test. 
      def teardown(&procedure)
        @context.teardown = procedure
      end
      alias_method :Teardown, :teardown

      # TODO: Make Before and After more generic to handle before and after
      # units, contexts/concerns, etc?

      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #
      #   unit :puts => "standard output (@stdout)" do
      #     puts "Hello"
      #   end
      #
      #   before /@stdout/ do
      #     $stdout = StringIO.new
      #   end
      #
      #   after /@stdout/ do
      #     $stdout = STDOUT
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def before(*matches, &procedure)
        @testcase.before[matches] = procedure
      end
      alias_method :Before, :before

      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # teardown code.
      #
      # @example
      #
      #   unit :puts => "standard output (@stdout)" do
      #     puts "Hello"
      #   end
      #
      #   before /@stdout/ do
      #     $stdout = StringIO.new
      #   end
      #
      #   after /@stdout/ do
      #     $stdout = STDOUT
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def after(*matches, &procedure)
        @testcase.after[matches] = procedure
      end
      alias_method :After, :after

      # Define a "before all" procedure.
      def prepare(&procedure)
        before(&procedure)
      end
      alias_method :Prepare, :prepare

      # Define an "after all" procedure.
      def cleanup(&procedure)
        after(&procedure)
      end
      alias_method :Cleanup, :cleanup

      # Load a helper script applicable to this test case. Unlike requiring
      # a helper script, the #helper method will eval the file's contents
      # directly into the test context (using instance_eval).
      #
      # @param [String] file
      #   File to eval into test context.
      #
      def helper(file)
        instance_eval(File.read(file), file)
      end
      alias_method :Helper, :helper

      #def include(*mods)
      #  extend *mods
      #end

      #def pending(message=nil)
      #  raise Pending.new(message)
      #end
    end

  end

end
