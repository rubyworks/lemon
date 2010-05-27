module Lemon
module Reporter
  require 'lemon/reporter/abstract'

  # Verbose Reporter
  class Verbose < Abstract

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
      puts
      puts "        FAIL #{exception.backtrace[0]}"
      puts "        #{exception}"
      puts
    end

    #
    def report_error(testunit, exception)
      puts red("* #{testunit} (ERROR)")
      puts
      puts "        ERROR #{exception.backtrace[0]}"
      puts "        #{exception}"
      puts
    end

    #
    def report_pending(testunit, exception)
      puts yellow("* #{testunit} (PENDING)")
      #puts
      #puts "        PENDING #{exception.backtrace[1]}"
      #puts
    end

    #
    def report_finish
      #puts

      #unless failures.empty?
      #  puts "FAILURES:\n\n"
      #  failures.each do |testunit, exception|
      #    puts "    #{testunit}"
      #    puts "    #{exception}"
      #    puts "    #{exception.backtrace[0]}"
      #    puts
      #  end
      #end

      #unless errors.empty?
      #  puts "ERRORS:\n\n"
      #  errors.each do |testunit, exception|
      #    puts "    #{testunit}"
      #    puts "    #{exception}"
      #    puts "    #{exception.backtrace[0]}"
      #    puts
      #  end
      #end

      #unless pendings.empty?
      #  puts "PENDING:\n\n"
      #  pendings.each do |testunit, exception|
      #    puts "    #{testunit}"
      #  end
      #  puts
      #end

=begin
      if cover?

        unless uncovered_cases.empty?
          unc = uncovered_cases.map do |mod|
            yellow(mod.name)
          end.join(", ")
          puts "\nUncovered Cases: " + unc
        end

        unless uncovered_units.empty?
          unc = uncovered_units.map do |unit|
            yellow(unit)
          end.join(", ")
          puts "\nUncovered Units: " + unc
        end

        #unless uncovered.empty?
        #  unc = uncovered.map do |unit|
        #    yellow(unit)
        #  end.join(", ")
        #  puts "\nUncovered: " + unc
        #end

        unless undefined_units.empty?
          unc = undefined_units.map do |unit|
            yellow(unit)
          end.join(", ")
          puts "\nUndefined Units: " + unc
        end

      end
=end

      #total = successes.size + failures.size + errors.size + pendings.size
      #tally = "\n#{total} tests: #{successes.size} pass, #{failures.size} fail, #{errors.size} err, #{pendings.size} pending"
      #if cover?
      #  tally += " (#{uncovered.size} uncovered, #{undefined.size} undefined)"
      #end

      puts
      puts tally
    end

  end

end
end

