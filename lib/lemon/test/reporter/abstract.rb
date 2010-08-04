module Lemon::Test
module Reporter

  # = Reporter Base Class
  class Abstract

    # Supports ANSI Codes?
    ANSI_SUPPORT = (
      begin
        require 'ansi/code'
        true
      rescue LoadError
        false
      end
    )

    def initialize(runner)
      @runner    = runner
      @ansicolor = ANSI_SUPPORT
    end

    #
    attr :runner

    #
    def report_start(suite)
    end

    def report_start_testcase(instance)
    end

    def report_instance(instance)
    end

    def report_start_testunit(testunit)
    end

    def report_success(testunit)
    end

    def report_failure(testunit, exception)
    end

    def report_error(testunit, exception)
    end

    def report_finish_testunit(testunit)
    end

    def report_finish_testcase(instance)
    end

    def report_finish
    end

    private

    def successes ; runner.successes ; end
    def failures  ; runner.failures  ; end
    def errors    ; runner.errors    ; end
    def pendings  ; runner.pendings  ; end

    #def uncovered_cases ; runner.uncovered_cases ; end
    #def uncovered_units ; runner.uncovered_units ; end
    #def undefined_units ; runner.undefined_units ; end

    #def uncovered ; runner.uncovered ; end
    #def undefined ; runner.undefined ; end

    ## Is coverage information requested?
    #def cover? ; runner.cover? ; end

    #
    def red(string)
      @ansicolor ? string.ansi(:red) : string
    end

    #
    def yellow(string)
      @ansicolor ? string.ansi(:yellow) : string
    end

    #
    def green(string)
      @ansicolor ? string.ansi(:green) : string
    end

    #
    def cyan(string)
      @ansicolor ? string.ansi(:cyan) : string
    end

    #
    def total
      successes.size + failures.size + errors.size + pendings.size
    end

    #
    def tally
      s = "#{total} tests: #{successes.size} pass, #{failures.size} fail, #{errors.size} err, #{pendings.size} pending "
      #s += "(#{uncovered_units.size} uncovered, #{undefined_units.size} undefined)" if cover?
      s
    end

  end

end
end

