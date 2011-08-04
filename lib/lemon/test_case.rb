#require 'lemon/model/pending'
#require 'lemon/model/test_context'
#require 'lemon/model/test_base_dsl'

require 'lemon/test_advice'
require 'lemon/test_subject'

module Lemon

  # Test Case encapsulates a collection of 
  # unit tests organized into groups of contexts.
  #
  class TestCase

    # The parent context in which this case resides.
    attr :context

    # Description of the test case.
    attr :description

    # List of tests and sub-contexts.
    attr :tests

    #
    attr :target

    # The setup and teardown advice.
    attr :subject

    # Advice are labeled procedures, such as before
    # and after advice.
    attr :advice

    # Module for parsing test case scripts.
    attr :dsl

    #
    attr_accessor :omit

    # A test case +target+ is a class or module.
    #
    # @param [TestSuite] context
    #   The test suite or parent case to which this
    #   case belongs.
    #
    # @param [Class,Module] target
    #   A description of the test-case's purpose.
    #
    def initialize(context, settings={}, &block)
      if context
        @context = context
        @advice  = context.advice.clone
      end

      @description = settings[:description]
      @subject     = settings[:subject]

      @tests   = []

      evaluate(&block)
    end

    # This has to be redefined in each subclass to pick
    # up there respective DSL classes.
    def evaluate(&block)
      @dsl = self.class.const_get(:DSL).new(self, &block)
    end

    # Iterate over each test and subcase.
    def each(&block)
      tests.each(&block)
    end

    # Number of tests plus subcases.
    def size
      tests.size
    end

    # Subclasses of TestCase can override this to describe
    # the type of test case they define.
    def type
      'Case'
    end

    #
    def to_s
      @description.to_s
    end

    #
    def omit?
      @omit
    end

    # Run test in the context of this case.
    #
    # @param [TestProc] test
    #   The test unit to run.
    #
    def run(test, &block)
      advice[:before].each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end

      block.call

      advice[:after].each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
    end

    #
    #--
    # TODO: Change so that the scope is the DSL
    #       and ** includes the DSL of the context ** !!!
    #++
    def scope
      @scope ||= (
        #if context
        #  scope = context.scope || Object.new
        #  scope.extend(dsl)
        #else
          scope = Object.new
          scope.extend(dsl)
        #end
        scope
      )
    end

    #
    class DSL

      include Lemon::DSL::Advice
      include Lemon::DSL::Subject

      #
      def initialize(context, &code)
        @context = context
        @subject = context.subject

        module_eval(&code)
      end

      #
      #--
      # @TODO: Instead of resuing TestCase can we have a TestContext
      #        that more generically mimics it's parent context?
      #++
      def Context(description, &block)
        @context.tests << TestCase.new(
          @context,
          :description => description,
          &block
        )
      end
      alias_method :context, :Context

      #
      def Test(description=nil, &procedure)
        test = TestUnit.new(
          @context, 
          :description => description,
          :subject     => @subject,
          &procedure
        )
        @context.tests << test
        test
      end
      alias_method :test, :Test

    end

  end

end
