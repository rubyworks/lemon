module Lemon
module Reporter
  require 'lemon/reporter/abstract'

  # Generic Reporter
  class DotProgress < Abstract

    def report_start(suite)
    end

    def report_concern(concern)
    end

    def report_success(testunit)
      print "."; $stdout.flush
    end

    def report_failure(testunit, exception)
      print "F"
    end

    def report_error(testunit, exception)
      print "E"
    end

    def report_pending(testunit, exception)
      print "P"
    end

    def report_finish #(successes, failures, errors, pendings)
      puts; puts

      unless failures.empty?
        puts "FAILURES:\n\n"
        failures.each do |testunit, exception|
          puts "    #{testunit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless errors.empty?
        puts "ERRORS:\n\n"
        errors.each do |testunit, exception|
          puts "    #{testunit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless pendings.empty?
        puts "PENDING:\n\n"
        pendings.each do |testunit, exception|
          puts "    #{testunit}"
        end
        puts
      end

      puts tally
    end

  end

end
end

