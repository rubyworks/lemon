module Lemon

  require 'lemon/test_module'

  # Subclass of TestModule used for classes.
  # It's basically the same class.
  #
  class TestClass < TestModule

    private

    #
    # Make sure the target is a class.
    #
    def validate_settings
      raise "#{@target} is not a module" unless Class === @target
    end

    #
    # The type of testcase.
    #
    def type
      'Class'
    end    

    # Evaluation scope for {TestClass}.
    #
    class DSL < TestModule::DSL

      #
      #
      #
      def context_class
        TestClass
      end

    end

  end

end
