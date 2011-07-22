module Lemon

  # Base class for TestCase DSLs.
  class BaseDSL < Module

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

    # Omit a test or test case from being run.
    #
    #  omit test "something or other" do
    #    # ...
    #  end
    #
    def omit(test_or_case)
      test_or_case.omit = true
    end
    alias_method :Omit, :omit

    # Setup is used to set things up for each unit test.
    # The setup procedure is run before each unit.
    #
    # @param [String] description
    #   A brief description of what the setup procedure sets-up.
    #
    def setup(description=nil, &procedure)
      if procedure
        @subject = TestSubject.new(@test_case, description, &procedure)
      end
    end

    alias_method :Setup, :setup

    alias_method :Concern, :setup
    alias_method :concern, :setup

    alias_method :Subject, :setup
    alias_method :subject, :setup

    # Teardown procedure is used to clean-up after each unit test.
    #
    def teardown(&procedure)
      @subject.teardown = procedure
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
      @context.before(matches, &procedure)
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
      @context.after(matches, &procedure)
    end

    alias_method :After, :after

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


# Before All and After All advice are bad form.
#
#    # Define a "before all" procedure.
#    def prepare(&procedure)
#      before(&procedure)
#    end
#
#    alias_method :Prepare, :prepare
#
#    # Define an "after all" procedure.
#    def cleanup(&procedure)
#      after(&procedure)
#    end
#
#    alias_method :Cleanup, :cleanup
#

  end

end
