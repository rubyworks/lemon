module Lemon

  require 'lemon/test_case'
  require 'lemon/test_method'
  require 'lemon/test_class_method'

  # The nomenclature of a TestModule limts the focus of testing
  # the methods of a module.
  #
  class TestModule < TestCase

    #
    # New unit test.
    #
    def initialize(settings={}, &block)
      @tested = false
      super(settings)
    end

    #
    # Make sure the target is a module.
    #
    def validate_settings
      raise "#{@target} is not a module" unless Module === @target
    end

    #
    # The type of test case.
    #
    def type
      'Module'
    end    

    #
    # Gives the name of the target module.
    #
    def to_s
      target.to_s
    end

    # Evaluation scope for TestModule.
    #
    class DSL < TestCase::DSL

      #
      # The class for which this is a DSL context.
      #
      def context_class
        TestModule
      end

      #
      # Define a method-unit subcase for the class/module testcase.
      #
      # @example
      #   unit :puts do
      #     test "print message with new line to stdout" do
      #       puts "Hello"
      #     end
      #   end
      #
      def unit(method, *tags, &block)
        return if @_omit

        meth = TestMethod.new(
          :context   => @_testcase, 
          :setup     => @_setup,
          :skip      => @_skip,
          :target    => method.to_sym,
          :tags      => tags,
          :singleton => false,
          &block
        )
        @_testcase.tests << meth
        meth
      end
      alias :Unit :unit

      #
      # More specific nomencalture for `#unit`.
      #
      alias :method :unit
      alias :Method :unit

      #
      # Define a class-method unit test for this case.
      #
      def class_unit(method, *tags, &block)
        return if @_omit

        meth = TestClassMethod.new(
          :context   => @_testcase,
          :setup     => @_setup,
          :skip      => @_skip,
          :target    => method.to_sym,
          :tags      => tags,
          :singleton => true,
          &block
        )

        @_testcase.tests << meth

        meth
      end
      alias :ClassUnit :class_unit

      #
      # More specific nomencalture for `#class_unit`.
      #
      alias :class_method :class_unit
      alias :ClassMethod :class_unit

    end

  end

end
