module Lemon

  # Test Subject - Setup and Teardown code.
  class TestSubject

    # The test case to which this advice belong.
    attr :context

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    attr :setup

    attr :teardown

    # New case instance.
    def initialize(context, description, options={}, &setup)
      @context      = context
      @description  = description.to_s
      #@function    = options[:function] || options[:singleton]
      #@type        = options[:type] || :context
      @setup        = [setup].flatten
      @teardown     = []
    end

    #
    def teardown=(procedure)
       @teardown = [procedure]
    end

    # Setup.
    def run_setup(scope)
      setup.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    # Teardown.
    def run_teardown(scope)
      teardown.each do |proc|
        scope.instance_eval(&proc)
      end
    end

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end
  end

  #
  module DSL

    #
    module Subject

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(description=nil, &procedure)
        if procedure
          @subject = TestSubject.new(@test_case, description, &procedure)
        end
      end

      alias_method :setup, :Setup

      alias_method :Concern, :Setup
      alias_method :concern, :Setup

      alias_method :Subject, :Setup
      alias_method :subject, :Setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&procedure)
        @subject.teardown = procedure
      end

      alias_method :teardown, :Teardown

    end

  end

end

=begin
  #
  class TestInstance < TestContext
  
    # Create instance.
    def setup(scope)
      if @block
        ins = scope.instance_eval(&@block)
        raise "target type mismatch" unless context.target === ins
      end
      ins
    end
  
  end

  #
  class TestSingleton < TestContext

    # Create instance.
    def setup(scope)
      if @block
        ins = scope.instance_eval(&@block)
        raise "target type mismatch" unless context.target == ins
      else
        ins = @context.target
      end
      ins
    end

    def function? ; true ; end
    alias_method :meta?, :function?

  end
=end
