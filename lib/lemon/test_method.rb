module Lemon

  require 'lemon/test_case'
  require 'lemon/test_proc'

  # The TestMethod class is a special TestCase that requires
  # a particular target method be tested.
  #
  class TestMethod < TestCase

    #
    # New unit test.
    #
    def initialize(settings={}, &block)
      @tested   = false
      super(settings)
    end

    #
    # Validate that a context and target method have been supplied.
    #
    def validate_settings
      raise "method test has no module or class context" unless @context
      raise "#{@target} is not a method name" unless Symbol === @target
    end

    #
    # Description of the type of test case.
    #
    def type
      'Method'
    end

    #
    # Used to make sure the the method has been tested, or not.
    #
    attr_accessor :tested

    #
    # If class method, returns target method's name prefixed with double colons.
    # If instance method, then returns target method's name prefixed with hash
    # character.
    #
    def name
      "##{target}"
    end

    # TODO: If sub-cases are to be supported than we need to incorporate
    #       the label into to_s.

    #
    # Returns the prefixed method name.
    #
    def to_s
      "##{target}"
    end

    #
    # Returns the fully qulaified name of the target method. This is
    # the standard interface used by Ruby Test.
    #
    def unit
      "#{context}##{target}"
    end

    #
    # Run test in the context of this case. Notice that #run for
    # TestMethod is more complex than a general TestCase. This is
    # to ensure that the target method is invoked during the course
    # of the test.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    # @yield
    #   The procedure for running the test.
    #
    def run(test, &block)
      target = self.target

      raise_pending(test.procedure) unless test.procedure

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
        super(test, &block)
        #block.call

      ensure
        target_class.class_eval %{
          alias_method "#{target}", "_lemon_#{target}"
        }
      end

      raise_pending(test.procedure) unless test.tested
    end

    #
    #
    #
    def raise_pending(procedure)
      if RUBY_VERSION < '1.9'
        Kernel.eval %[raise NotImplementedError, "#{target} not tested"], procedure
      else
        Kernel.eval %[raise NotImplementedError, "#{target} not tested"], procedure.binding
      end
    end

    #
    # The target class.
    #
    def target_class
      @target_class ||= context.target
    end

    #
    #
    #
    def class_method?
      false
    end

    # Scope for evaluating method test definitions.
    #
    class DSL < TestCase::DSL

      #
      # Define a unit test for this case.
      #
      # @example
      #   test "print message with new line to stdout" do
      #     puts "Hello"
      #   end
      #
      def test(label=nil, *tags, &block)
        block = @_omit.to_proc if @_omit
        test  = TestProc.new(
          :context => @_testcase,
          :setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          &block
        )
        @_testcase.tests << test
        test
      end
      alias :Test :test

      #
      # Create a sub-case of the method case.
      #
      def context(label, *tags, &block)
        @_testcase.tests << TestMethod.new(
          :context => @_testcase,
          :target  => @_testcase.target,
          :setup   => @_setup,
          :skip    => @_skip,
          :label   => label,
          :tags    => tags,
          &block
        )
      end
      alias :Context :context

      #
      # Omit tests.
      #
      # @example
      #   omit "reason" do
      #     test do
      #       ...
      #     end
      #   end
      #
      def omit(label=true, &block)
        @_omit = Omission.new(label, :backtrace=>caller)
        block.call
        @_omit = nil
      end
      alias :Omit :omit

      #
      # Skip tests. Unlike omit, skipped tests are not executed at all.
      #
      # @example
      #   skip "reason" do
      #     test do
      #       ...
      #     end
      #   end
      #
      def skip(label=true, &block)
        @_skip = label
        block.call
        @_skip = nil
      end
      alias :Skip :skip

    end

  end

end
