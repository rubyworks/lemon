require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Timed Reporter
  class Tap < Abstract

    #
    def start_suite(suite)
      @start = Time.now
      @i = 0
      n = suite.test_cases.inject(0){ |c, tc| c = c + tc.size; c }
      puts "1..#{n}"
    end

    def start_unit(unit)
      @i += 1
    end

    #
    def pass(unit)
      puts "ok #{@i} - #{unit.description}"
    end

    #
    def fail(unit, exception)
      puts "not ok #{@i} - #{unit.description}"
      puts "  FAIL #{exception.backtrace[0]}"
      puts "  #{exception}"
    end

    #
    def error(unit, exception)
      puts "not ok #{@i} - #{unit.description}"
      puts "  ERROR #{exception.class}"
      puts "  #{exception}"
      puts "  " + exception.backtrace.join("\n        ")
    end

    #
    def pending(unit, exception)
      puts "not ok #{@i} - #{unit.description}"
      puts "  PENDING"
      puts "  #{exception.backtrace[1]}"
    end
  end

end

