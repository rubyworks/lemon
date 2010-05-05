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
    def initialize(concern, target, options={}, &procedure)
      concern.assign(self)

      @concern   = concern
      @testcase  = concern.testcase

      @target    = target

      @aspect    = options[:aspect]
      @meta      = options[:metaclass]

      @procedure = procedure
    end

    # Is this unit test for a meta-method?
    def meta?
      @meta
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

    # If meta-method return target method's name prefixed with double colons.
    # If instance method then return target method's name.
    def key
      meta? ? "::#{target}" : "#{target}"
    end

    # If meta-method return target method's name prefixed with double colons.
    # If instance method then return target method's name prefixed with hash character.
    def name
      meta? ? "::#{target}" : "##{target}"
    end

    #
    def fullname
      meta? ? "#{testcase}::#{target}" : "#{testcase}##{target}"
    end

    #
    def to_s
      if meta?
        "#{testcase}.#{target} #{aspect}"
      else
        "#{testcase}##{target} #{aspect}"
      end
    end

    #
    def match?(match)    
      match == target || match === aspect
    end
  end

end



