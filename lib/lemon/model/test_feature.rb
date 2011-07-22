require 'lemon/model/pending'
require 'lemon/model/test_context'
require 'lemon/model/test_advice'

module Lemon

  # The TestFeature ...
  #
  class TestFeature < TestCase

    # The parent context in which this case resides.
    attr :context

    # Test target is a description of the case.
    attr :target

    # List of tests and sub-contexts.
    attr :tests

    # The advice (e.g. setup and teardown) to use.
    attr :advice

    # Before matching test units.
    attr :before
    #attr_accessor :prepare

    # After matching test units.
    attr :after
    #attr_accessor :cleanup

    # Module for parsing test case scripts.
    attr :dsl

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

      @advice  = options[:advice]

      @tests   = []

      @before = {}
      @after  = {}

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
    #def prepare
    #  @before[[]]
    #end

    #
    #def cleanup
    #  @after[[]]
    #end

    #
    attr_accessor :omit

    #
    def omit?
      @omit
    end

    #
    def description
      @target.to_s
    end

    # Run test in the context of this case.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    def eval(test)
      test.advice.setup(scope)
      scope.instance_exec(&test)
      test.advice.teardown(scope)
    end

    #
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
    class DSL < Module

      #
      def initialize(context, &code)
        @case   = context
        @advice = context.advice
        module_eval(&code)
      end

      #
      def context(description, &block)
        @context.tests << TestCase.new(@context, description, &block)
      end

      #
      def scenario(description, &block)
        @context.tests << TestScenario.new(
          @context,
          description,
          &procedure
        )
      end

      #
      def test(description, &procedure)
        @context.tests << TestProc.new(
          @context,
          description,
          &procedure
        )
      end

=begin
      # Define a unit test for this case.
      #
      # @example
      #   unit :puts => "print message with new line to stdout" do
      #     puts "Hello"
      #   end
      #
      def method(target_method, &block)
        meth = TestUnit.new(
          @test_case, target_method,
          :function => false,
          :context  => @context,
          :caller   => caller,
          &block
        )
        @test_case.units << meth
        meth
      end
      alias_method :Method, :method

      # Define a class-method unit test for this case.
      #
      # @deprecated
      #   New way to test class methods is to create a separate
      #   test case using `TestCase Foo.singlton_class do` ?
      #
      def class_method(target_method, &block)
        meth = TestUnit.new(
          @test_case, target_method,
          :function => true,
          :context  => @context,
          :caller   => caller,
          &block
        )
        @test_case.units << meth
        meth
      end
      alias_method :ClassMethod, :class_method
=end

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
          @advice = TestAdvice.new(@test_case, description, &procedure)
        end
      end

      alias_method :Setup, :setup

      alias_method :Concern, :setup
      alias_method :concern, :setup

      #alias_method :Subject, :setup
      #alias_method :subject, :setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def teardown(&procedure)
        @advice.teardown = procedure
      end

      alias_method :Teardown, :teardown

      # TODO: Allow Before and After to handle before and after
      # concerns in addition to units?

      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #
      #    unit :puts do
      #      test "standard output (@stdout)" do
      #        puts "Hello"
      #      end
      #
      #      before /@stdout/ do
      #        $stdout = StringIO.new
      #      end
      #
      #      after /@stdout/ do
      #        $stdout = STDOUT
      #      end
      #    end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def before(*matches, &procedure)
        @context.before[matches] = procedure
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
      #    unit :puts do
      #      test "standard output (@stdout)" do
      #        puts "Hello"
      #      end
      #
      #      before /@stdout/ do
      #        $stdout = StringIO.new
      #      end
      #
      #      after /@stdout/ do
      #        $stdout = STDOUT
      #      end
      #    end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def after(*matches, &procedure)
        @context.after[matches] = procedure
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
      # FIXME: This is at odds with loading helpers automatically. How
      # to handle?
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
