module Lemon::TestReports

  # Test Reporter Base Class
  class Abstract

    require 'ansi/code'

    #
    def self.inherited(base)
      registry << base
    end

    #
    def self.registry
      @registry ||= []
    end

    #
    def initialize(runner)
      @runner = runner
    end

    #
    attr :runner

    #
    def start_suite(suite)
    end

    #
    def start_case(instance)
    end

    #
    #def instance(instance)
    #end

    #
    def start_unit(unit)
    end

    # Report an omitted unit test.
    def omit(unit)
    end

    #
    def pass(unit)
    end

    #
    def fail(unit, exception)
    end

    #
    def error(unit, exception)
    end

    #
    def finish_unit(testunit)
    end

    #
    def finish_case(instance)
    end

    #
    def finish_suite(suite)
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
    #def red(string)
    #  @ansicolor ? string.ansi(:red) : string
    #end

    #
    #def yellow(string)
    #  @ansicolor ? string.ansi(:yellow) : string
    #end

    #
    #def green(string)
    #  @ansicolor ? string.ansi(:green) : string
    #end

    #
    #def cyan(string)
    #  @ansicolor ? string.ansi(:cyan) : string
    #end

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

