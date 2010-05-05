module Lemon

  # = Reporter Base Class
  class Reporter

    # Supports ANSI Codes?
    ANSI_SUPPORT = (
      begin
        require 'ansi/code'
        true
      rescue LoadError
        false
      end
    )

    # TODO: make Reporter#factory more dynamic
    def self.factory(format, runner)
      format = format.to_s if format
      case format
      when 'v', 'verb', 'verbose'
        Reporters::Verbose.new(runner)
      when 'o', 'out', 'outline'
        Reporters::Outline.new(runner)
      else
        Reporters::DotProgress.new(runner)
      end
    end

    def initialize(runner)
      @runner    = runner
      @ansicolor = ANSI_SUPPORT
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

    def uncovered ; runner.uncovered ; end
    def undefined ; runner.undefined ; end

    # Is coverage information requested?
    def cover? ; runner.cover? ; end

    #
    def red(string)
      @ansicolor ? ANSI::Code.red{ string } : string
    end

    #
    def yellow(string)
      @ansicolor ? ANSI::Code.yellow{ string } : string
    end

    #
    def green(string)
      @ansicolor ? ANSI::Code.green{ string } : string
    end

    #
    def total
      successes.size + failures.size + errors.size + pendings.size
    end

    #
    def tally
      s = "#{total} tests: #{successes.size} pass, #{failures.size} fail, #{errors.size} err, #{pendings.size} pending "
      s += "(#{uncovered.size} uncovered, #{undefined.size} undefined)" if cover?
      s
    end

  end

end
