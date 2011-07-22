require 'lemon/model/test_context'
require 'lemon/model/test_proc'

module Lemon

  # The TestMethod class is a special TestCase that requires
  # a particular target method be tested.
  #
  class TestMethod < TestCase

    #
    #attr :caller

    # New unit test.
    def initialize(context, target, options={}, &block)
      @context   = context
      @target    = target

      @advice    = context.advice.clone

      @subject   = options[:subject]

      @function  = options[:function]
      @omit      = options[:omit]
      #@caller    = options[:caller]

      @tests    = []

      @tested   = false
      #@prepare = nil
      #@cleanup = nil

      evaluate(&block) if block
    end

    #
    def evaluate(&block)
      @dsl = DSL.new(self, &block)
    end

    # Used to make the the method tested or not.
    attr_accessor :tested

    # Is this unit for a class or module level method?
    def function?
      @function
    end

    alias_method :class_method?, :function?

    # If meta-method return target method's name prefixed with double colons.
    # If instance method then return target method's name.
    def key
      function? ? "::#{target}" : "#{target}"
    end

    # If meta-method return target method's name prefixed with double colons.
    # If instance method then return target method's name prefixed with hash character.
    def name
      function? ? "::#{target}" : "##{target}"
    end

    #
    def fullname
      function? ? "#{context}.#{target}" : "#{context}##{target}"
    end

    #
    def to_s
      if function?
        "#{context}.#{target}"
      else
        "#{context}##{target}"
      end
    end

    #
    def description
      if function?
        #"#{context} .#{target} #{aspect}"
        "#{context}.#{target} #{context} #{aspect}".strip
      else
        a  = /^[aeiou]/i =~ context.to_s ? 'An' : 'A'
        #"#{a} #{context} receiving ##{target} #{aspect}"
        "#{context}##{target} #{context} #{aspect}".strip
      end
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
        if context
          scope = context.scope || Object.new
          scope.extend(dsl)
        else
          scope = Object.new
          scope.extend(dsl)
        end
        scope
      )
    end

    #
    class DSL < BaseDSL

      # TODO: Should TestMethod context handle sub-contexts?
      def context(description, &block)
        @context.tests << TestMethod.new(@context, @context.target, :aspect=>description, &block)
      end

      # Define a unit test for this case.
      #
      # @example
      #   test "print message with new line to stdout" do
      #     puts "Hello"
      #   end
      #
      def test(aspect=nil, &block)
        test = TestProc.new( 
          @context,
          :subject  => @subject,
          :aspect   => aspect,
          :caller   => caller,
          &block
        )
        @context.tests << test
        test
      end
      alias_method :Test, :test

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

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def setup(description=nil, &procedure)
        if procedure
          @subject = TestSubject.new(@context, description, &procedure)
        end
      end
      alias_method :Setup, :setup

      alias_method :Concern, :setup
      alias_method :concern, :setup

      # Teardown procedure is used to clean-up after each unit test. 
      #
      def teardown(&procedure)
        @subject.teardown = procedure
      end
      alias_method :Teardown, :teardown

      # TODO: Make Before and After more generic to handle before and after
      # units, contexts/concerns, etc?

      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #
      #    method :puts do
      #      test "standard output (@stdout)" do
      #        puts "Hello"
      #      end
      #
      #      before /@stdout/ do
      #        $stdout = StringIO.new
      #      end
      #
      #      after /@stdout/ do
      #        $stdout = STDOUT
      #      end
      #    end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def before(*matches, &procedure)
        @context.before(matches, &procedure)
      end
      alias_method :Before, :before

      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # teardown code.
      #
      # @example
      #
      #   unit :puts => "standard output (@stdout)" do
      #     puts "Hello"
      #   end
      #
      #   before /@stdout/ do
      #     $stdout = StringIO.new
      #   end
      #
      #   after /@stdout/ do
      #     $stdout = STDOUT
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def after(*matches, &procedure)
        @context.after(matches, &procedure)
      end
      alias_method :After, :after
=end

    end

  end

end

