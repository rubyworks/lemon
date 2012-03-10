module Lemon

  require 'lemon/test_method'

  # Subclass of TestMethod used for class methods.
  # It's basically the same class.
  #
  class TestClassMethod < TestMethod

    # Description of the type of test case.
    def type
      'Class Method'
    end

    # If class method, returns target method's name prefixed with double colons.
    # If instance method, then returns target method's name prefixed with hash
    # character.
    def name
      "::#{target}"
    end

    # Returns the prefixed method name.
    def to_s
      "::#{target}"
    end

    # Returns the fully qulaified name of the target method. This is
    # the standard interface used by RubyTest.
    def unit
      "#{context}.#{target}"
    end

    # For a class method, the target class is the meta-class.
    def target_class
      @target_class ||= (class << context.target; self; end)
    end

    #
    def class_method?
      true
    end

    # Scope for evaluating class method test definitions.
    #
    class DSL < TestMethod::DSL

      #
      # The class for which this is a DSL context.
      #
      def context_class
        TestClassMethod
      end

    end

  end

end
