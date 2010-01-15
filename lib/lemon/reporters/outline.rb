module Lemon
module Reporters

  require 'lemon/reporter'

  # Outline Reporter
  class Outline < Reporter

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
      puts green("* #{testunit}")
    end

    #
    def report_failure(testunit, exception)
      puts red("* #{testunit} (FAILURE)")
      #puts
      #puts "        FAIL #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def report_error(testunit, exception)
      puts red("* #{testunit} (ERROR)")
      #puts
      #puts "        ERROR #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def report_pending(testunit, exception)
      puts yellow("* #{testunit} (PENDING)")
      #puts
      #puts "        PENDING #{exception.backtrace[0]}"
      #puts
    end

    #
    def report_finish
      puts

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

      #unless pendings.empty?
      #  puts "PENDING:\n\n"
      #  pendings.each do |testunit, exception|
      #    puts "    #{testunit}"
      #  end
      #  puts
      #end

      total = successes.size + failures.size + errors.size + pendings.size
      puts "#{total} tests, #{successes.size} pass, #{failures.size} failures, #{errors.size} errors, #{pendings.size} pending"
    end

  end

end
end

