module Lemon::CoverReports

  class Abstract

    require 'ansi/core'

    def initialize(coverage)
      @coverage  = coverage
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
    def tally
      c = covered_units.size
      u = uncovered_units.size
      t = c + u

      pc = c * 100 / t
      pu = u * 100 / t

      "#{pc}% #{c}/#{t} covered, #{pu}% #{u}/#{t} uncovered" + 
      " (#{undefined_units.size} undefined units, #{uncovered_cases.size} uncovered cases)"
    end

  end

end

