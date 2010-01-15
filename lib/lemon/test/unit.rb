module Lemon::Test

  #
  class Unit

    # The test case to which this unit test belongs.
    attr :testcase

    # The concern which this test helps ensure.
    attr :concern

    # A test unit +target+ is a method.
    attr :target

    # The aspect of the concern this test fulfills.
    attr :aspect

    # Test procedure, in which test assertions should be made.
    attr :procedure

    # New unit test.
    def initialize(concern, target, aspect=nil, &procedure)
      concern.assign(self)

      @concern   = concern
      @testcase  = concern.testcase

      @target    = target
      @aspect    = aspect
      @procedure = procedure
    end

    # This method has the other end of the BIG FAT HACK. See Suite#const_missing.
    def call
      raise Pending unless procedure
      begin
        Lemon.test_stack << self  # hack
        procedure.call
      ensure
        Lemon.test_stack.pop
      end
    end

    # The suite to which this unit test belongs.
    def suite
      testcase.suite
    end

    #
    def to_s
      "#{testcase}##{target} #{aspect}"
    end

  end

end



