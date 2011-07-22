require 'lemon/model/pending'
require 'lemon/model/test_context'
require 'lemon/model/test_advice'
require 'lemon/model/test_subject'
require 'lemon/model/test_base_dsl'

module Lemon

  # Test Case encapsulates a collection of 
  # unit tests organized into groups of contexts.
  #
  class TestCase

    # The parent context in which this case resides.
    attr :context

    # Test target is a description of the case.
    attr :target

    # List of tests and sub-contexts.
    attr :tests

    # The setup and teardown advice.
    attr :subject

    # The before and after advice.
    attr :advice

    # Before matching test units.
    attr :before
    #attr_accessor :prepare

    # After matching test units.
    attr :after
    #attr_accessor :cleanup

    # Module for parsing test case scripts.
    attr :dsl

    #
    attr_accessor :omit

    # A test case +target+ is a class or module.
    #
    # @param [TestSuite] suite
    #   The test suite to which the case belongs.
    #
    # @param [Class,Module] target
    #   A description of the test-case's purpose.
    #
    def initialize(context, target, options={}, &block)
      @context = context
      @target  = target

      @advice  = context.advice.clone
      @subject = context.subject

      @tests   = []

      evaluate(&block)
    end

    # This has to be redefined in each subclass to pick
    # up there respective DSL classes.
    def evaluate(&block)
      @dsl = DSL.new(self, &block)
    end

    # Iterate over each test unit.
    def each(&block)
      tests.each(&block)
    end

    #
    def size
      tests.size
    end

    #
    def to_s
      target.to_s.sub(/^\#\<.*?\>::/, '')
    end

    #
    def description
      @target.to_s
    end

    #
    #def prepare
    #  @before[[]]
    #end

    #
    #def cleanup
    #  @after[[]]
    #end

    #
    def omit?
      @omit
    end

    #
    def before(*matches, &procedure)
      @advice.before[matches] = procedure
    end

    #
    def after(*matches, &procedure)
      @advice.after[matches] = procedure
    end

    # Run test in the context of this case.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    #def eval(test)
    #  test.advice.setup(scope)
    #  scope.instance_exec(&test)
    #  test.advice.teardown(scope)
    #end

    #
    def run(test, &block)
      block.call
    end

    # TODO: Change so that the scope is the DSL, and includes the DSL of the context?
    def scope
      @scope ||= (
        if context
          scope = context.scope || Object.new
          scope.extend(dsl)
        else
          scope = Object.new
          scope.extend(dsl)
        end
      )
    end

    #
    class DSL < BaseDSL

      #
      def initialize(context, &code)
        @context = context
        @subject = context.subject

        module_eval(&code)
      end

      #
      def context(description, &block)
        @context.tests << TestCase.new(@context, description, &block)
      end

      #
      def test(description, &procedure)
        test = TestProc.new(
          @context, 
          :aspect  => description,
          :subject => subject,
          &procedure
        )
        @context.tests << test
        test
      end

    end

  end

end
