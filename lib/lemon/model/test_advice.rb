module Lemon

  # Test Advice
  class TestAdvice

    # The test case to which this advice belongs.
    #attr :context

    attr :before

    attr :after

    # New case instance.
    def initialize
      @before = {}
      @after  = {}
    end

    #
    def initialize_copy(original)
      @before = original.before.clone
      @after  = original.after.clone
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
