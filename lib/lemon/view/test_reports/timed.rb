require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

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
      data = [timer, clock, green("SUCCESS"), testunit.to_s, testunit.description]
      puts "%11s  %11s  %19s  %s  %s" % data
    end

    #
    def report_failure(testunit, exception)
      data = [timer, clock, red("FAILURE"), red("#{testunit.description}")]
      puts "%11s  %11s  %19s  %s" % data
      #puts
      #puts "        FAIL #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def report_error(testunit, exception)
      data = [timer, clock, red("ERROR  "), red("#{testunit.description}")]
      puts "%11s  %11s  %19s  %s" % data
      #puts
      #puts "        ERROR #{exception.class}"
      #puts "        #{exception}"
      #puts "        " + exception.backtrace.join("\n        ")
      #puts
    end

    #
    def report_pending(testunit, exception)
      data = [timer, clock, yellow("PENDING"), yellow("#{testunit.description}")]
      puts "%11s  %11s  %19s  %s" % data
    end

    #
    def report_finish(suite)
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

