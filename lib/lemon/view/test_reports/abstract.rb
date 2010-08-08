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

    def record ; runner.record ; end

    #def uncovered_cases ; runner.uncovered_cases ; end
    #def uncovered_units ; runner.uncovered_units ; end
    #def undefined_units ; runner.undefined_units ; end

    #def uncovered ; runner.uncovered ; end
    #def undefined ; runner.undefined ; end

    ## Is coverage information requested?
    #def cover? ; runner.cover? ; end

    #
    def total
      %w{pending pass fail error omit}.inject(0){ |s,r| s += record[r.to_sym].size; s }
    end

    #
    def tally
      sizes = %w{pending pass fail error omit}.map{ |r| record[r.to_sym].size }

      data = [total] + sizes

      s = "%s tests: %s pending, %s pass, %s fail, %s err, %s omit " % data
      #s += "(#{uncovered_units.size} uncovered, #{undefined_units.size} undefined)" if cover?
      s
    end

  end

end

