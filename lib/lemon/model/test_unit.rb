module Lemon

  #
  class TestUnit

    # The test case to which this unit test belongs.
    attr :testcase

    # The context to use for this test.
    attr :context

    # A test unit +target+ is a method.
    attr :target

    # The aspect of the instance this test fulfills.
    attr :aspect

    # Test procedure, in which test assertions should be made.
    attr :procedure

    # New unit test.
    def initialize(testcase, target, options={}, &procedure)
      @testcase  = testcase
      @target    = target

      @aspect    = options[:aspect]
      @function  = options[:function] || options[:metaclass]
      @context   = options[:context]
      @omit      = options[:omit]

      @procedure = procedure

      @tested    = false
    end

    #
    def name ; @target ; end

    # Is this unit test for a class or module level method?
    def function?
      @function
    end
    alias_method :meta?, :function?

    #
    def omit?
      @omit
    end

    #
    attr_accessor :tested

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
      meta? ? "#{testcase}.#{target}" : "#{testcase}##{target}"
    end

    #
    def to_s
      if meta?
        "#{testcase}.#{target}"
      else
        "#{testcase}##{target}"
      end
    end

    #
    def description
      if meta?
        "#{testcase} #{instance} .#{target} #{aspect}"
      else
        a  = /^[aeiou]/i =~ testcase.to_s ? 'An' : 'A'
        "#{a} #{testcase} #{instance} receiving ##{target} #{aspect}"
      end
    end

    #
    def match?(match)    
      match == target || match === aspect
    end
  end

end

