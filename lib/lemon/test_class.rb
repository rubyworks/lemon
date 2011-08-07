module Lemon

  require 'lemon/test_module'

  # Subclass of TestModule used for classes.
  # It's essentailly the same class.
  #
  class TestClass < TestModule

    private

    #
    def validate_target
      raise unless Class === @target
    end

    #
    class DSL < TestModule::DSL
    end

  end

end
