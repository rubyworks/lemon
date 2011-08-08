module Lemon

  require 'lemon/test_case'
  require 'lemon/test_method'

  # The nomenclature of a TestModule limts the focus of testing
  # the methods of a module.
  #
  class TestModule < TestCase

    # New unit test.
    def initialize(settings={}, &block)
      @tested = false
      super(settings)
    end

    #
    def validate_settings
      raise "#{@target} is not a module" unless Module === @target
    end

    #
    def type
      'Module'
    end    

    #
    def to_s
      target.to_s
    end

    #
    class Scope < TestCase::Scope

      # Define a method/unit subcase for the class/module testcase.
      #
      # @example
      #   unit :puts do
      #     test "print message with new line to stdout" do
      #       puts "Hello"
      #     end
      #   end
      #
      def unit(method, &block)
        meth = TestMethod.new(
          :context  => @_testcase, 
          :setup    => @_setup,
          :target   => method.to_sym,
          :function => false,
          &block
        )
        @_testcase.tests << meth
        meth
      end
      alias :Unit :unit

      # More specific nomencalture for `#unit`.
      alias :method :unit
      alias :Method :unit

      # Define a class-method unit test for this case.
      #
      def class_unit(method, &block)
        meth = TestMethod.new(
          :context  => @_testcase,
          :setup    => @_setup,
          :target   => method.to_sym,
          :function => true,

          &block
        )
        @_testcase.tests << meth
        meth
      end
      alias :ClassUnit :class_unit

      # More specific nomencalture for `#class_unit`.
      alias :class_method :class_unit
      alias :ClassMethod  :class_unit

      # Alternate nomenclature for class_unit.
      alias :Function :ClassMethod
      alias :function :ClassMethod

      #--
      # TODO: Allow sub-cases?
      #++

      # Create a subcase of module testcase.
      def context(label, &block)
        @_testcase.tests << TestModule.new(
          :context => @_testcase,
          :target  => @_testcase.target,
          :setup   => @_setup,
          :label   => label,
          &block
        )
      end
      alias :Context :context

    end

  end

end
