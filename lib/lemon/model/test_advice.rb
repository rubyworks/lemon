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

end
