module Lemon

  # Test Instances are used to organize unit tests into groups, so as to address
  # specific scenarios for a given class.
  class TestContext

    # The test case to which this concern belongs.
    attr :testcase

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # New case instance.
    def initialize(testcase, description, options={}, &block)
      @testcase    = testcase
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
        ins = scope.instance_eval(&@block)
      end
      ins
    end

    def function? ; false ; end
    alias_method :meta?, :function?

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end
  end

  ##
  #class TestInstance < TestContext
  #
  #  # Create instance.
  #  def setup(scope)
  #    if @block
  #      ins = scope.instance_eval(&@block)
  #      raise "target type mismatch" unless testcase.target === ins
  #    end
  #    ins
  #  end
  #
  #end

=begin
  #
  class TestSingleton < TestContext

    # Create instance.
    def setup(scope)
      if @block
        ins = scope.instance_eval(&@block)
        raise "target type mismatch" unless testcase.target == ins
      else
        ins = @testcase.target
      end
      ins
    end

    def function? ; true ; end
    alias_method :meta?, :function?

  end
=end

end

