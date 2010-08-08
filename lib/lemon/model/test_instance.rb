module Lemon

  # Test Instances are used to organize unit tests into groups, so as to address
  # specific scenarios for a given class.
  class TestInstance

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
      if function?
        if @block
          ins = scope.instance_eval(&@block)
          raise "target type mismatch" unless testcase.target == ins
        else
          ins = @testcase.target
        end
      else
        if @block
          ins = scope.instance_eval(&@block)
          raise "target type mismatch" unless testcase.target === ins
        end
      end
      ins
    end

    def function?
      @function
    end
    alias_method :meta?, :function?

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end
  end

end

