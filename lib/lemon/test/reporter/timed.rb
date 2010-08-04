module Lemon::Test
module Reporter

  require 'lemon/test/reporter/abstract'

  # Timed Reporter
  class Timed < Abstract

    #
    def report_start(suite)
      @start = Time.now
      timer_reset
      puts
    end

    #
    #def report_instance(instance)
    #  puts
    #  puts "== #{concern.description}\n\n" unless concern.description.empty?
    #  timer_reset
    #end

    def report_start_testunit(testunit)
      timer_reset
    end

    #
    def report_success(testunit)
      into = [clock, timer, green("SUCCESS"), testunit.to_s, testunit.description]
      puts "%12s  %12s  %20s  %s  %s" % into
    end

    #
    def report_failure(testunit, exception)
      puts "%12s  %12s  %20s  %s" % [clock, timer, red("FAILURE"), red("#{testunit.description}")]
      puts
      puts "        FAIL #{exception.backtrace[0]}"
      puts "        #{exception}"
      puts
    end

    #
    def report_error(testunit, exception)
      puts "%12s  %12s  %20s  %s" % [clock, timer, red("ERROR  "), red("#{testunit.description}")]
      puts
      puts "        ERROR #{exception.class}"
      puts "        #{exception}"
      puts "        " + exception.backtrace.join("\n        ")
      puts
    end

    #
    def report_pending(testunit, exception)
      puts "%12s  %12s  %20s  %s" % [clock, timer, yellow("PENDING"), yellow("#{testunit.description}")]
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

    #
    def clock
      secs = Time.now - @start
      return "%0.5fs" % [secs.to_s]
    end

    #
    def timer
      secs  = Time.now - @time
      @time = Time.now
      return "%0.5fs" % [secs.to_s]
    end

    #
    def timer_reset
      @time = Time.now
    end

  end

end
end

