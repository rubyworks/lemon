module Lemon

  # Generic Reporter
  class Reporter

    def report_start(suite)
    end

    def report_success(testunit)
      print "."
    end

    def report_failure(testunit, exception)
      #puts exception
      print "F"
    end

    def report_error(testunit, exception)
      #puts exception
      print "E"
    end

    def report_finish(successes, failures, errors)
      puts; puts

      failures.each do |testunit, exception|
        puts "    #{testunit}"
        puts "    #{exception}"
        puts
      end

      errors.each do |testunit, exception|
        puts "    #{testunit}"
        puts "    #{exception}"
        puts
      end

      total = successes.size + failures.size + errors.size
      puts "#{total} tests, #{failures.size} failures, #{errors.size} errors"
    end

  end

end
