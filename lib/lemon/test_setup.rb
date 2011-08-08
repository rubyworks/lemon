module Lemon

  # Test Subject - Setup and Teardown code.
  class TestSetup

    # The test case to which this advice belong.
    attr :context

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # Setup procedure.
    attr :setup

    # Teardown procedure.
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
