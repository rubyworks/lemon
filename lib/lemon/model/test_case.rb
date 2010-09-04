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

    # List of testunit that are skipped.
    #attr :skip

    # Before all units are run.
    attr_accessor :prepare

    # After all units are run.
    attr_accessor :cleanup

    # Module for parsing test case scripts.
    attr :dsl

    # A test case +target+ is a class or module.
    def initialize(suite, target, aspect=nil, &block)
      @suite  = suite
      @target = target
      @aspect = aspect

      #@steps  = []
      @units  = []

      @prepare = nil
      @cleanup = nil

      #@before = {}
      #@after  = {}

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
    class DSL < Module
      #
      def initialize(testcase, &casecode)
        @testcase = testcase
        @context = nil #Instance.new(self)
        module_eval(&casecode)
      end

      #
      def prepare(&block)
        @testcase.prepare = block
      end
      alias_method :Prepare, :prepare

      #
      def cleanup(&block)
        @testcase.cleanup = block
      end
      alias_method :Cleanup, :cleanup

      # Define a unit test for this case.
      def unit(*target, &block)
        target = target.map{ |x| Hash === x ? x.to_a : x }.flatten
        method, aspect = *target
        unit = TestUnit.new(
          @testcase, method,
          :function => false,
          :aspect   => aspect,
          :context => @context,
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
          :context => @context,
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

      #
      #def Omit(*target, &block)
      #  target = target.map{ |x| Hash === x ? x.to_a : x }.flatten
      #  method, aspect = *target
      #  skip = TestUnit.new(
      #    @testcase, method,
      #    :aspect   => aspect,
      #    :function => @function,
      #    :context => @context,
      #    :omit => true,
      #    &block
      #  )
      #  #@testcase.steps << skip
      #end
      #alias_method :omit, :Omit

      #
      def context(description=nil, &block)
        if block
          context  = TestContext.new(@testcase, description, &block)
          @context = context
          #@testcase.steps << context
        end
      end
      alias_method :Context, :context

      # DEPRECATE: Concern in favor of Context ?
      alias_method :Concern, :context
      alias_method :concern, :context

      # Define a new test instance for this case.
      def instance(description=nil, &block)
        context  = TestInstance.new(@testcase, description, &block)
        @context = context
        @function = false
        #@testcase.steps << context
      end
      alias_method :Instance, :instance

      # Define a new test singleton for this case.
      #def Singleton(description=nil, &block)
      #  context  = TestSingleton.new(@testcase, description, &block)
      #  @context = context
      #  @function = true
      #  #@testcase.steps << context
      #end
      #alias_method :singleton, :Singleton

      def teardown(&block)
        @context.teardown = block
      end
      alias_method :Teardown, :teardown

      # Load a helper script applicable to this test case.
      def helper(file)
        instance_eval(File.read(file), file)
      end
      alias_method :Helper, :helper

=begin
      # TODO: Make Before and After more generic to handle before and after
      # units, conctexts, instances, singletons, all three types of concern
      # and cases.

      # Define a before procedure for this case.
      def Before(*matches, &block)
        @testcase.before[matches] = block
      end
      alias_method :before, :Before

      # Define an after procedure for this case.
      def After(*matches, &block)
        @testcase.after[matches] = block
      end
      alias_method :after, :After
=end

      #def include(*mods)
      #  extend *mods
      #end

      #
      #def pending
      #  raise Pending
      #end
    end

  end

end
