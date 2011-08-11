module Lemon

  # Test procedure.
  #
  class TestProc

    # New test procedure.
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

    # Target method of context.
    def target
      context.target
    end

    #
    attr_accessor :skip

    # Don't run test?
    def skip?
      @skip
    end

    # Has this test been executed?
    attr_accessor :tested

    # Test label.
    def to_s
      label.to_s
    end

    alias_method :name, :to_s

    # Ruby Test looks for #topic as the description of test setup.
    def topic
      setup.to_s
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

    #
    #def name
    #  if function?
    #    "#{test_case}.#{target}"
    #  else
    #    "#{test_case}##{target}"
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
    # The file_and_line method returns the file name and line number of
    # the caller created upon initialization of this object.
    #
    # This method is cached.
    #
    # Examples
    #   file_and_line #=> ['foo_test.rb', 123]
    #
    # Returns Array of file name and line number of caller.
    def source_location
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
