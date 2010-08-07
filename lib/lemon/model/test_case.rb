require 'lemon/model/pending'
require 'lemon/model/test_instance'
require 'lemon/model/test_unit'

module Lemon

  # Test Case encapsulates a collection of 
  # unit tests organized into groups of instance.
  class TestCase

    # The test suite to which this testcase belongs.
    attr :suite

    # A testcase +target+ is a class or module.
    attr :target

    # Description of the aspect of the test class/module
    # to be testd.
    attr :aspect

    # Ordered list of testunits.
    attr :testunits

    # List of before procedures that apply case-wide.
    attr :before

    # List of after procedures that apply case-wide.
    attr :after

    # A test case +target+ is a class or module.
    def initialize(suite, target, aspect=nil, &block)
      @suite          = suite
      @target         = target
      @aspect         = aspect

      @testunits      = []

      @before = {}
      @after  = {}

      DSL.new(self, &block)
    end

    # Iterate over each test instance.
    def each(&block)
      testunits.each(&block)
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
        @instance = nil #Instance.new(self)
        module_eval(&casecode)
      end

      # Define a unit test for this case.
      def TestUnit(*targets, &block)
        targets_hash = Hash===targets.last ? targets.pop : {}
        targets_hash.each do |target_method, aspect|
          @testcase.testunits << TestUnit.new(
            @testcase, target_method,
            :aspect=>aspect, :metaclass=>@meta, :instance=>@instance, &block
          )
        end
        targets.each do |target_method|
          @testcase.testunits << TestUnit.new(
            @testcase, target_method,
            :metaclass=>@meta, :instance=>@instance, &block
          )
        end
      end
      alias_method :testunit, :TestUnit
      alias_method :Unit, :TestUnit
      alias_method :unit, :TestUnit

      # Define a meta-method unit test for this case.
      #def MetaUnit(*targets, &block)
      #  targets_hash = Hash===targets.last ? targets.pop : {}
      #  targets_hash.each do |target_method, target_concern|
      #    @testunits << Unit.new(self, target_method, :aspect=>target_concern, :metaclass=>true, &block)
      #  end
      #  targets.each do |target_method|
      #    @testunits << Unit.new(self, target_method, :metaclass=>true, &block)
      #  end
      #end
      #alias_method :metaunit, :MetaUnit

      # Define a new test instance for this case.
      def Instance(description=nil, &block)
        @meta = false
        if block
          instance  = TestInstance.new(@testcase, description, &block)
          @instance = instance
          #@testcase.steps << instance
        else
          @instance = nil
        end
      end
      alias_method :instance, :Instance

      # Define a new test instance for this case.
      def Singleton(description=nil, &block)
        @meta     = true
        instance  = TestInstance.new(@testcase, description, :singleton=>true, &block)
        @instance = instance
        #@testcase.steps << instance
      end
      alias_method :singleton, :Singleton

      # Load a helper script applicable to this test case.
      def helper(file)
        instance_eval(File.read(file), file)
      end

      # NOTE: Due to a limitation in Ruby this does not
      # provived access to submodules. A hack has been used
      # to circumvent. See Suite.const_missing.
      def include(*mods)
        extend *mods
      end

      # DEPRECATE before and after ?

      # Define a before procedure for this case.
      def Before(*matches, &block)
        matches = [nil] if matches.empty?
        matches.each do |match|
          @testcase.before[match] = block
        end
      end
      alias_method :before, :Before

      # Define an after procedure for this case.
      def After(*matches, &block)
        matches = [nil] if matches.empty?
        matches.each do |match|
          @testcase.after[match] = block
        end
      end
      alias_method :after, :After

      def Teardown
        # TODO
      end
      alias_method :teardown, :Teardown

      # Define a instance procedure to apply case-wide.
      #def When(match=nil, &block)
      #  @when_clauses[match] = block #<< Advice.new(match, &block)
      #end

      #
      #def pending
      #  raise Pending
      #end
    end

  end

end

