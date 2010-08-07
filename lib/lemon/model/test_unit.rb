module Lemon

  #
  class TestUnit

    # The test case to which this unit test belongs.
    attr :testcase

    # The instance which this test helps ensure.
    attr :instance

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
      @instance  = options[:instance]

      @procedure = procedure

      @tested    = false
    end

    # Is this unit test for a class or module level method?
    def function?
      @function
    end
    alias_method :meta?, :function?

    #
    attr_accessor :tested

    # This method has the other end of the BIG FAT HACK. See Suite#const_missing.
    def call(scope)
      this = self
      base = meta? ? (class << testcase.target; self; end) : testcase.target
      raise Pending unless procedure
      base.class_eval do
        alias_method :__lemon__, this.target
        define_method(this.target) do |*a,&b|
          this.tested = true
          __lemon__(*a,&b)
        end
      end
      #Lemon.test_stack << self  # hack
      begin
        if instance && procedure.arity != 0
          scope.instance_exec(instance.setup, &procedure) #procedure.call
        else
          scope.instance_exec(&procedure) #procedure.call
        end
        # TODO: teardown
      ensure
        #Lemon.test_stack.pop
        base.class_eval %{
          alias_method :#{target}, :__lemon__
        }
      end
      if !tested
        #exception = Untested.new("#{target} not tested")
        Kernel.eval %[raise Pending, "#{target} not tested"], procedure
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

