module Lemon

  require 'lemon/test_case'
  require 'lemon/test_unit'

  # The TestMethod class is a special TestCase that requires
  # a particular target method be tested.
  #
  class TestMethod < TestCase

    # New unit test.
    def initialize(context, settings={}, &block)
      @context     = context
      @advice      = context.advice.clone

      @target      = settings[:target]
      @description = settings[:description]
      @function    = settings[:function]
      @subject     = settings[:subject]
      @omit        = settings[:omit]

      @tests       = []

      @tested      = false

      evaluate(&block) if block
    end

    #
    #def evaluate(&block)
    #  @dsl = DSL.new(self, &block)
    #end

    #
    def type
      if function?
        'Function'
      else
        'Method'
      end
    end

    # Used to make sure the the method has been tested, or not.
    attr_accessor :tested

    # Is this method a class method?
    def function?
      @function
    end

    #
    alias_method :class_method?, :function?

    #
    def to_s
      if function?
        "::#{target}"
      else
        "##{target}"
      end
    end

    #
    #def description
    #  if function?
    #    #"#{context} .#{target} #{aspect}"
    #    "#{context}.#{target} #{context} #{aspect}".strip
    #  else
    #    a  = /^[aeiou]/i =~ context.to_s ? 'An' : 'A'
    #    #"#{a} #{context} receiving ##{target} #{aspect}"
    #    "#{context}##{target} #{context} #{aspect}".strip
    #  end
    #end

    ## If meta-method return target method's name prefixed with double colons.
    ## If instance method then return target method's name.
    #def key
    #  function? ? "::#{target}" : "#{target}"
    #end

    ## If meta-method return target method's name prefixed with double colons.
    ## If instance method then return target method's name prefixed with hash character.
    #def name
    #  function? ? "::#{target}" : "##{target}"
    #end

    # Returns the fully qulaified name of the target method.
    def unit
      function? ? "#{context}.#{target}" : "#{context}##{target}"
    end

=begin
    #
    def start_test
      this   = self
      target = self.target

      #raise Pending unless test.to_proc

      begin
        target_class.class_eval do
          alias_method "_lemon_#{target}", target
          define_method(target) do |*a,&b|
            this.tested = true
            __send__("_lemon_#{target}",*a,&b)
          end
        end
      rescue => error
        Kernel.eval <<-END, test.to_proc.binding
          raise #{error.class}, "#{target} not tested"
        END
      end
    end

    #
    def finish_test
      target_class.class_eval %{
        alias_method "#{target}", "_lemon_#{target}"
      }

      if !tested
        #exception = Untested.new("#{test.target} not tested")
        if RUBY_VERSION < '1.9'
          Kernel.eval %[raise Pending, "#{target} not tested"], test.to_proc
        else
          Kernel.eval %[raise Pending, "#{target} not tested"], test.to_proc.binding
        end
      end
    end
=end

    # Run test in the context of this case. Notice that #run for
    # TestMethod is more complex than a general TestCase. This is
    # to ensure that the target method is invoked during the course
    # of the test.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    def run(test, &block)
      target = self.target

      raise Pending unless test.procedure

      begin
        target_class.class_eval do
          alias_method "_lemon_#{target}", target
          define_method(target) do |*a,&b|
            test.tested = true
            __send__("_lemon_#{target}",*a,&b)
          end
        end
      rescue => error
        Kernel.eval <<-END, test.to_proc.binding
          raise #{error.class}, "#{target} not tested"
        END
      end

      begin
        block.call

      ensure
        target_class.class_eval %{
          alias_method "#{target}", "_lemon_#{target}"
        }
      end

      if !test.tested
        #exception = Untested.new("#{test.target} not tested")
        if RUBY_VERSION < '1.9'
          Kernel.eval %[raise Pending, "#{target} not tested"], test.to_proc
        else
          Kernel.eval %[raise Pending, "#{target} not tested"], test.to_proc.binding
        end
      end
    end

    # The scope in which to run the test procedures.
    def scope
      @scope ||= (
        #if context
        #  scope = context.scope || Object.new
        #  scope.extend(dsl)
        #else
          scope = Object.new
          scope.extend(dsl)
        #end
        scope
      )
    end

    #
    def target_class
      @target_class ||= (
        if function? 
          (class << context.target; self; end)
        else
          context.target
        end
      )
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

      # TODO: Should TestMethod context handle sub-contexts?
      def Context(description, &block)
        @context.tests << TestMethod.new(@context, @context.target, :aspect=>description, &block)
      end
      alias_method :context, :Context

      # Define a unit test for this case.
      #
      # @example
      #   test "print message with new line to stdout" do
      #     puts "Hello"
      #   end
      #
      def Test(description=nil, &block)
        test = TestUnit.new( 
          @context,
          :subject     => @subject,
          :description => description,
          &block
        )
        @context.tests << test
        test
      end
      alias_method :test, :Test

=begin
      # Omit a test from testing.
      #
      # @example
      #   omit test do
      #     ...
      #   end
      #
      def omit(test)
        test.omit = true
      end
      alias_method :Omit, :omit
=end

    end

  end

end
