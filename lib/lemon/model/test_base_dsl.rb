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
        :description => description,
        :subject     => subject,
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
