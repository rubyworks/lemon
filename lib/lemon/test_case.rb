require 'lemon/core_ext'
require 'lemon/test_advice'
require 'lemon/test_setup'
require 'lemon/test_world'
require 'lemon/test_scope'

module Lemon

  # Test Case serves as the base class for Lemon's
  # specialized test case classes.
  #
  class TestCase

    # The parent context in which this case resides.
    attr :context

    # Brief description of the test case.
    attr :label

    # Target component.
    attr :target

    # The setup and teardown advice.
    attr :setup

    # Advice are labeled procedures, such as before
    # and after advice.
    attr :advice

    # List of tests and sub-contexts.
    attr :tests

    # Skip execution of test case?
    attr :skip

    #
    # A test case +target+ is a class or module.
    #
    # @param [Hash] settings
    #   The settings used to define the test case.
    #
    # @option settings [TestCase] :context
    #   Parent test case.
    #
    # @option settings [Module,Class,Symbol] :target
    #   The testcase's target.
    #
    # @option settings [String] :label
    #   Breif description of testcase.
    #   (NOTE: this might not be used)
    #
    # @option settings [TestSetup] :setup
    #   Test setup.
    #
    # @option settings [Boolean] :skip
    #   If runner should skip test.
    #
    def initialize(settings={}, &block)
      @context = settings[:context]
      @target  = settings[:target]
      @label   = settings[:label]
      @setup   = settings[:setup]
      @skip    = settings[:skip]
      @tags    = settings[:tags]

      @advice  = @context ? @context.advice.dup : TestAdvice.new

      @tests   = []
      @domain  = domain_class.new(self)

      validate_settings

      evaluate(&block)
    end

    #
    # Subclasses can override this methof to validate settings. 
    # It is run just before evaluation of scope block.
    #
    def validate_settings
    end

    # 
    def domain
      @domain
    end

    #
    #
    #
    def evaluate(&block)
      @domain.module_eval(&block)
    end

    #
    # Iterate over each test and subcase.
    #
    def each(&block)
      tests.each(&block)
    end

    #
    # Number of tests and subcases.
    #
    def size
      tests.size
    end

    #
    # Subclasses of TestCase can override this to describe
    # the type of test case they define.
    #
    def type
      'Test Case'
    end

    #
    #
    #
    def to_s
      @label.to_s
    end

    #
    #
    #
    def skip?
      @skip
    end

    #
    #
    #
    def skip!(reason=true)
      @skip = reason
    end

    #
    #
    #
    def tags
      @tags
    end

    #
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
    # Module for evaluating test case script.
    #
    # @return [Scope] evaluation scope
    #
    def scope
      @scope ||= TestScope.new(self)
    end

    #
    # Get the domain class dynamically so that each subclass
    # of TestCase will retrieve it's own.
    #
    def domain_class
      self.class.const_get(:DSL)
    end

    #
    class DSL < World

      #
      #
      #
      def initialize(testcase) #, &code)
        @_testcase = testcase
        @_setup    = testcase.setup
        @_skip     = nil

        extend testcase.context.scope if testcase.context

        #module_eval(&code)
      end

      #
      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def setup(description=nil, &procedure)
        if procedure
          @_setup = TestSetup.new(@test_case, description, &procedure)
        end
      end
      alias :Setup :setup

      #
      # Original Lemon nomenclature for `#setup`.
      #
      alias :concern :setup
      alias :Concern :setup

      #
      # Teardown procedure is used to clean-up after each unit test.
      #
      def teardown(&procedure)
        @_setup.teardown = procedure
      end
      alias :Teardown :teardown

      # TODO: Allow Before and After to handle setup and teardown?
      #       But that would only allow one setup per case.

      #
      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def before(*matches, &procedure)
        @_testcase.advice[:before][matches] = procedure
      end
      alias :Before :before

      #
      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # teardown code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def after(*matches, &procedure)
        @_testcase.advice[:after][matches] = procedure
      end
      alias :After :after

      # TODO: non-block skip

      #
      # Set skip flag.
      #
      def skip(reason=true, &block)
        @_skip = reason
        block.call
        @_skip = nil
      end

      #--
      # THINK: Instead of resuing TestCase can we have a TestContext
      #        or other way to more generically mimics the parent context?
      #++

      # TODO: Should we allow sub-cases?

      #
      # Create a subcase of module testcase.
      #
      def context(label, *tags, &block)
        @_testcase.tests << context_class.new(
          :context => @_testcase,
          :target  => @_testcase.target,
          :setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          &block
        )
      end
      alias :Context :context

      #
      #
      #
      def context_class
        TestCase
      end

    end

  end

end
