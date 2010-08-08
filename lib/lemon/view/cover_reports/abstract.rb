module Lemon::CoverReports

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

    def initialize(coverage)
      @coverage  = coverage
      @ansicolor = ANSI_SUPPORT
    end

    #
    attr :coverage

    #
    def render
    end

    def covered_units
      coverage.covered
    end

    def uncovered_units
      coverage.uncovered
    end

    def undefined_units
      coverage.undefined
    end

    def uncovered_cases
      coverage.uncovered_cases
    end

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
    def tally
      "#{covered_units.size} covered units, #{uncovered_units.size} uncovered units, #{undefined_units.size} undefined units, #{uncovered_cases.size} uncovered cases"
    end

  end

end

