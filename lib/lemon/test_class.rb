module Lemon

  require 'lemon/test_module'

  # Subclass of TestModule used for classes.
  # It's basically the same class.
  #
  class TestClass < TestModule

    private

    #
    def validate_target
      raise unless Class === @target
    end

    #
    def type
      'Class'
    end    

    #
    class Scope < TestModule::Scope
    end

  end

end
