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
      puts "#{concern.description}\n\n" unless concern.description.empty?
    end

    #
    def report_success(testunit)
      puts "[PASS] #{testunit.target} #{testunit.aspect}"
    end

    #
    def report_failure(testunit, exception)
      puts "[FAIL] #{testunit.target} #{testunit.aspect}"
      puts "       #{exception}"
      puts "       #{exception.backtrace[0]}"
    end

    #
    def report_error(testunit, exception)
      puts "[ERROR] #{testunit.target} #{testunit.aspect}"
      puts "        #{exception}"
      puts "        #{exception.backtrace[0]}"
    end

    #
    def report_pending(testunit, exception)
      puts "[SKIP] #{testunit.target} #{testunit.aspect}"
      puts "       #{exception.backtrace[0]}"
    end

    #
    def report_finish
      puts

=begin
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
=end

      total = successes.size + failures.size + errors.size + pendings.size
      puts "#{total} tests, #{successes.size} pass, #{failures.size} failures, #{errors.size} errors, #{pendings.size} pending"
    end

  end

end
end

