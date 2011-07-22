module Lemon

  # The nomenclature of a TestModule limts the focus of testing
  # the methods of a module.
  #
  class TestModule < TestCase

    def evaluate(&block)
      @dsl = DSL.new(self, &block)
    end

    #
    class DSL < BaseDSL

      # Define a method test for the class/module case.
      #
      # @example
      #   method :puts do
      #     test "print message with new line to stdout" do
      #       puts "Hello"
      #     end
      #   end
      #
      def method(method, &block)
        meth = TestMethod.new(
          @context, method,
          :function => false,
          :subject  => @subject,
          #:caller   => caller,
          &block
        )
        @context.tests << meth
        meth
      end

      # Capitalized alias for #method.
      alias_method :Method, :method

      # Define a class-method unit test for this case.
      #
      def class_method(method, &block)
        meth = TestMethod.new(
          @context,
          method,
          :function => true,
          :subject  => @subject,
          #:caller   => caller,
          &block
        )
        @context.tests << meth
        meth
      end

      # Capitalized alis of #class_method.
      alias_method :ClassMethod, :class_method

      # Alternate alias for #class_method.
      alias_method :function, :class_method
      alias_method :Function, :class_method


      # STILL ALLOW GENERIC CASES ?

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

    end

  end

end
