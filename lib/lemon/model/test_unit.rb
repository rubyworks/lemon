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

    #
    attr :caller

    # New unit test.
    def initialize(testcase, target, options={}, &procedure)
      @testcase  = testcase
      @target    = target

      @aspect    = options[:aspect]
      @function  = options[:function] || options[:metaclass]
      @context   = options[:context]
      @omit      = options[:omit]
      @caller    = options[:caller]

      @procedure = procedure

      @tested    = false
    end

    #
    attr_accessor :omit

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
        #"#{testcase} .#{target} #{aspect}"
        "#{testcase}.#{target} #{context} #{aspect}".strip
      else
        a  = /^[aeiou]/i =~ testcase.to_s ? 'An' : 'A'
        #"#{a} #{testcase} receiving ##{target} #{aspect}"
        "#{testcase}##{target} #{context} #{aspect}".strip
      end
    end

    # START-COMMIT. 201105190006

    # The file method returns the file name of +caller+ which
    # was created upon initialization of this object. It is
    # also the first element of #file_and_line.
    #
    # Returns file name of caller.
    def file
      file_and_line.first
    end

    # Returns line number of caller.
    def line
      file_and_line.last
    end

    # The file_and_line method returns the file name and line number of
    # the caller created upon initialization of this object.
    #
    # This method is cached.
    #
    # Examples
    #   file_and_line #=> ['foo_test.rb', 123]
    #
    # Returns Array of file name and line number of caller.
    def file_and_line
      @file_and_line ||= (
        line = caller[0]
        i = line.rindex(':in')
        line = i ? line[0...i] : line
        f, l = File.basename(line).split(':')
        [f, l]
      )
    end

    # END-COMMIT.

    #
    def match?(match)    
      match == target || match === aspect
    end
  end

end

