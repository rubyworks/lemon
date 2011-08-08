module Lemon

  #
  class TestUnit

    # New unit test procedure.
    #
    def initialize(settings={}, &procedure)
      @context = settings[:context]
      @setup   = settings[:setup]
      @label   = settings[:label]
      @skip    = settings[:skip]

      @procedure = procedure

      @tested    = false
    end

  public

    # The parent case to which this test belongs.
    attr :context

    # Setup and teardown procedures.
    attr :setup

    # Description of test.
    attr :label

    # Test procedure, in which test assertions should be made.
    attr :procedure

    #
    #attr :caller

    # 
    def target
      context.target
    end

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
    attr_accessor :skip

    #
    def skip?
      @skip
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
      label.to_s
    end

    alias_method :name, :to_s

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

    # TODO: handle parameterized tests
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
    def call
      context.run(self) do
        setup.run_setup(scope)    if setup
        scope.instance_exec(*arguments, &procedure)
        setup.run_teardown(scope) if setup
      end
    end

    #
    def scope
      context.scope
    end

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
