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
