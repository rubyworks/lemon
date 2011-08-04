module Lemon

  #
  class TestUnit

    # New unit test procedure.
    #
    def initialize(context, options={}, &procedure)
      @context     = context

      @subject     = options[:subject]
      @description = options[:description]
      @omit        = options[:omit]

      @procedure   = procedure

      @tested      = false
    end

  public

    # The parent case to which this test belongs.
    attr :context

    # Setup and teardown procedures.
    attr :subject

    # 
    def target
      context.target
    end

    # Description of test.
    attr :description

    # Test procedure, in which test assertions should be made.
    attr :procedure

    #
    #attr :caller

    # The before and after advice from the context.
    def advice
      context.advice
    end

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
    attr_accessor :tested

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
      description.to_s
    end

    alias_method :name, :to_s

    #
    def scope
      context.scope
    end

    #
    #def description
    #  if function?
    #    #"#{test_case} .#{target} #{aspect}"
    #    "#{test_case}.#{target} #{context} #{aspect}".strip
    #  else
    #    a  = /^[aeiou]/i =~ test_case.to_s ? 'An' : 'A'
    #    #"#{a} #{test_case} receiving ##{target} #{aspect}"
    #    "#{test_case}##{target} #{context} #{aspect}".strip
    #  end
    #end

    def arguments
      []
    end

    #
    def to_proc
      lambda do
        call
      end
    end

    #
    def match?(match)    
      match == target || match === description
    end

    #
    #def start_test
    #  advice.setup(context.scope) if advice
    #end

    #
    def call
      context.run(self) do
        subject.run_setup(scope)    if subject
        scope.instance_exec(*arguments, &procedure)
        subject.run_teardown(scope) if subject
      end
    end

    #
    #def finish_test
    #  advice.teardown(context.scope) if advice
    #end

=begin
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
=end

  end

end
