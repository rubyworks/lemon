module Lemon
module Reporters

  require 'lemon/reporter'

  # Generic Reporter
  class Verbose < Reporter

    #
    def report_start(suite)
    end

    #
    def report_concern(concern)
      puts
      puts concern.description
    end

    #
    def report_success(testunit)
      puts "* [PASS] #{testunit}"
    end

    #
    def report_failure(testunit, exception)
      puts "* [FAIL] #{testunit.target}"
      #puts exception
    end

    #
    def report_error(testunit, exception)
      puts "* [ERROR] #{testunit.target}"
      #puts exception
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
end

