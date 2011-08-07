module Lemon

  require 'lemon/test_case'
  require 'lemon/test_method'

  # The nomenclature of a TestModule limts the focus of testing
  # the methods of a module.
  #
  class TestModule < TestCase

    # New unit test.
    def initialize(target, settings={}, &block)
      @target      = target

      validate_target

      @context     = settings[:context]
      @description = settings[:description]
      @subject     = settings[:subject]
      @skip        = settings[:skip]

      if @context
        @advice    = @context.advice.clone
      else
        @advice    = TestAdvice.new
      end

      @tests       = []

      @tested      = false

      evaluate(&block) if block
    end

    #
    def validate_target
      raise "#{@target} is not a module" unless Module === @target
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
      alias :method :Method

      # Unit nomenclature.
      alias :Unit :Method
      alias :unit :Method

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

      # Unit nomenclature.
      alias :ClassUnit :ClassMethod
      alias :class_unit :ClassMethod

      # TODO: Should we allow subcases here?
      def Context(description, &block)
        @context.tests << TestModule.new(
          @context.target,
          :context     => @context,
          :description => description,
          &block
        )
      end

      alias :context :Context

#      # TODO: Should we allow general test units?
#      def Test(description, &procedure)
#        test = TestUnit.new(
#          @context, 
#          :description => description,
#          :subject     => @subject,
#          &procedure
#        )
#        @context.tests << test
#        test
#      end
#
#      alias :test :Test

    end

  end

end
