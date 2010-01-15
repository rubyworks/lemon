module Lemon

  # = Reporter Base Class
  class Reporter

    # TODO: make Reporter#factory more dynamic
    def self.factory(format, runner)
      format = format.to_sym if format
      case format
      when :verbose
        Reporters::Verbose.new(runner)
      when :outline
        Reporters::Outline.new(runner)
      else
        Reporters::DotProgress.new(runner)
      end
    end

    def initialize(runner)
      @runner = runner
      require_ansicolor
    end

    #
    attr :runner

    #
    def report_start(suite)
    end

    def report_concern(concern)
    end

    def report_success(testunit)
    end

    def report_failure(testunit, exception)
    end

    def report_error(testunit, exception)
    end

    def report_finish
    end

    private

    def successes ; runner.successes ; end
    def failures  ; runner.failures  ; end
    def errors    ; runner.errors    ; end
    def pendings  ; runner.pendings  ; end

    #
    def require_ansicolor
      begin
        require 'ansi/code'
        @ansicolor = true
      rescue LoadError
        @ansicolor = false
      end
    end

    def red(string)
      @ansicolor ? ANSI::Code.red{ string } : string
    end

    def yellow(string)
      @ansicolor ? ANSI::Code.yellow{ string } : string
    end

    def green(string)
      @ansicolor ? ANSI::Code.green{ string } : string
    end

  end

end
