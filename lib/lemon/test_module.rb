module Lemon

  require 'lemon/test_case'
  require 'lemon/test_method'

  # The nomenclature of a TestModule limts the focus of testing
  # the methods of a module.
  #
  class TestModule < TestCase

    # New unit test.
    def initialize(context, settings={}, &block)
      if context
        @context   = context
        @advice    = context.advice.clone
      else
        @context   = nil
        @advice    = TestAdvice.new
      end

      @target      = settings[:target]
      @description = settings[:description]
      @subject     = settings[:subject]
      @skip        = settings[:skip]

      @tests       = []

      @tested      = false

      evaluate(&block) if block
    end

    #def evaluate(&block)
    #  @dsl = DSL.new(self, &block)
    #end

    def type
      if ::Class === target
        'Class'
      else
        'Module'
      end
    end    

    #
    def to_s
      target.to_s
    end

    #
    class DSL < Module

      include Lemon::DSL::Advice
      include Lemon::DSL::Subject

      #
      def initialize(context, &code)
        @context = context
        @subject = context.subject

        module_eval(&code)
      end

      # Define a method subcase for the class/module case.
      #
      # @example
      #   Method :puts do
      #     Test "print message with new line to stdout" do
      #       puts "Hello"
      #     end
      #   end
      #
      def Method(method, &block)
        meth = TestMethod.new(
          @context, 
          :target   => method,
          :function => false,
          :subject  => @subject,
          &block
        )
        @context.tests << meth
        meth
      end

      # Capitalized alias for #method.
      alias_method :method, :Method

      # Define a class-method unit test for this case.
      #
      def ClassMethod(method, &block)
        meth = TestMethod.new(
          @context,
          :target   => method,
          :function => true,
          :subject  => @subject,
          &block
        )
        @context.tests << meth
        meth
      end
      alias :class_method :ClassMethod

      # Alternate alias for #ClassMethod.
      alias :Function :ClassMethod
      alias :function :ClassMethod

      # TODO: Should we allow subcases here?
      def Context(description, &block)
        @context.tests << TestModule.new(
          @context,
          :target      => @context.target,
          :description => description,
          &block
        )
      end
      alias_method :context, :Context

      # TODO: Should we allow general test units?
      def Test(description, &procedure)
        test = TestUnit.new(
          @context, 
          :description => description,
          :subject     => @subject,
          &procedure
        )
        @context.tests << test
        test
      end
      alias_method :test, :Test

    end

  end

end
