module Lemon

  # Test Subject - Setup and Teardown code.
  class TestSubject

    # The test case to which this advice belong.
    attr :context

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # New case instance.
    def initialize(context, description, options={}, &setup)
      @context      = context
      @description  = description.to_s
      #@function    = options[:function] || options[:singleton]
      #@type        = options[:type] || :context
      @setup        = setup
    end

    #
    def teardown=(procedure)
       @teardown = procedure
    end

    #
    def start_test
      setup(context.scope)
    end

    #
    def finish_test
      teardown(context.scope)
    end

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
