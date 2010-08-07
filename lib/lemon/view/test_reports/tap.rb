require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Timed Reporter
  class Tap < Abstract

    #
    def report_start(suite)
      @start = Time.now
      @i = 0
      n = suite.testcases.inject(0){ |c, tc| c = c + tc.size; c }
      puts "1..#{n}"
    end

    def report_start_testunit(testunit)
      @i += 1
    end

    #
    def report_success(testunit)
      puts "ok #{@i} - #{testunit.description}"
    end

    #
    def report_failure(testunit, exception)
      puts "not ok #{@i} - #{testunit.description}"
      puts "  FAIL #{exception.backtrace[0]}"
      puts "  #{exception}"
    end

    #
    def report_error(testunit, exception)
      puts "not ok #{@i} - #{testunit.description}"
      puts "  ERROR #{exception.class}"
      puts "  #{exception}"
      puts "  " + exception.backtrace.join("\n        ")
    end

    #
    def report_pending(testunit, exception)
      puts "not ok #{@i} - #{testunit.description}"
      puts "  PENDING"
      puts "  #{exception.backtrace[1]}"
    end
  end

end

