module Lemon

  # Test Advice
  class TestAdvice

    # The test case to which this advice belongs.
    #attr :context

    #
    attr :table

    # New case instance.
    def initialize
      @table = Hash.new{ |h,k| h[k] = {} }
    end

    #
    def initialize_copy(original)
      @table = original.table.clone
    end

    #
    def [](type)
      @table[type.to_sym]
    end

=begin
    #
    #def teardown=(procedure)
    #   @teardown = procedure
    #end

    # Setup.
    def setup(scope=nil)
      if scope
        scope.instance_eval(&@setup)
      else
        @setup
      end
    end

    # Teardown.
    def teardown(scope=nil)
      if scope
        scope.instance_eval(&@teardown) if @teardown
      else
        @teardown
      end
    end

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end
=end

  end


  module DSL

    #
    #--
    # TODO: Allow Before and After to handle before and after
    #       concerns in addition to units?
    #++
    module Advice

      # Define a _complex_ before procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # setup code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the before procedure.
      #
      def Before(*matches, &procedure)
        @context.advice[:before][matches] = procedure
      end

      alias_method :before, :Before

      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of tests to be defined that share special
      # teardown code.
      #
      # @example
      #   Method :puts do
      #     Test "standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     Before /@stdout/ do
      #       $stdout = StringIO.new
      #     end
      #
      #     After /@stdout/ do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Array<Symbol,Regexp>] matches
      #   List of match critera that must _all_ be matched
      #   to trigger the after procedure.
      #
      def After(*matches, &procedure)
        @context.advice[:after][matches] = procedure
      end

      alias_method :after, :After

    end

  end

end
