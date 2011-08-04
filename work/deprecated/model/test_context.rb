=begin
module Lemon

  #
  class TestContext

    # The test case to which this concern belongs.
    attr :test_case

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # New case instance.
    def initialize(test_case, description, options={}, &block)
      @test_case   = test_case
      @description = description.to_s
      @function    = options[:function] || options[:singleton]
      @type        = options[:type] || :context
      @block       = block
    end

    #
    def teardown=(procedure)
       @teardown = procedure
    end

    # Teardown instance.
    def teardown(scope=nil)
      if scope
        scope.instance_eval(&@teardown) if @teardown
      else
        @teardown
      end
    end

    # Create instance.
    def setup(scope)
      if @block
        scope.instance_eval(&@block)
      end
    end

    def function? ; false ; end
    alias_method :meta?, :function?

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end
  end

end
=end

=begin
  #
  class TestInstance < TestContext
  
    # Create instance.
    def setup(scope)
      if @block
        ins = scope.instance_eval(&@block)
        raise "target type mismatch" unless test_case.target === ins
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
        raise "target type mismatch" unless test_case.target == ins
      else
        ins = @test_case.target
      end
      ins
    end

    def function? ; true ; end
    alias_method :meta?, :function?

  end
=end

