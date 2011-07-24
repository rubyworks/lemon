module Lemon

  #
  class TestClause

    # New unit test procedure.
    #
    def initialize(scenario, description, options={}) #, &procedure)
      @context     = scenario
      @description = description

      @type        = options[:type]

      #@subject   = options[:subject]
      #@aspect    = options[:aspect]
      #@omit      = options[:omit]

      #@procedure = procedure

      @tested    = false
    end

    attr :type

  public

    # The case to which this test belongs.
    attr :context

    # Setup and teardown procedures.
    #attr :subject

    # 
    #def target
    #  context.
    #end

    # Description of test.
    attr :description

    # Test procedure, in which test assertions should be made.
    #attr :procedure

    # The before and after advice from the context.
    #def advice
    #  context.advice
    #end

    #
    #def name ; @target ; end

    # Is this unit test for a class or module level method?
    #def function?
    #  context.function?
    #end

    #
    attr_accessor :omit

    #
    def omit?
      @omit
    end

    #
    #attr_accessor :tested

    #
    #def to_s
    #  if function?
    #    "#{test_case}.#{target}"
    #  else
    #    "#{test_case}##{target}"
    #  end
    #end

    #
    def to_s
      "#{type.to_s.capitalize} #{description}"
    end

    #
    def subject
    end

    #
    def scope
      context.scope
    end

    #
    def to_proc
      lambda{ call }
    end

    #
    #def match?(match)    
    #  match == target || match === aspect
    #end

    #
    def call
      context.run(self) do
        #subject.run_setup(scope)    if subject
        scope.instance_exec(*arguments, &procedure)
        #subject.run_teardown(scope) if subject
      end
    end

  end

end
