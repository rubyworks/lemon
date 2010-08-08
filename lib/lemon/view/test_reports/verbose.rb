require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Timed Reporter
  class Verbose < Abstract

    LAYOUT = "  %-12s  %11s  %11s    %s %s"

    #
    def start_suite(suite)
      @start = Time.now
      timer_reset
    end

    #
    def start_case(tc)
      @just_started = true
      puts
      puts tc.to_s.ansi(:bold)
      puts
    end

    #
    def instance(instance)
       puts unless @just_started
       puts "  #{instance}"
       puts
       @just_started = false
    end

    #
    def start_unit(unit)
       instance = unit.instance
       if @instance != instance
         @instance = instance
         instance(instance)
       end
       timer_reset
    end

    #
    def omit(unit)
      data = ["OMIT".ansi(:cyan), timer, clock, unit.name.ansi(:bold), unit.aspect]
      puts LAYOUT % data
      #puts "  %s  %s  %s" % ["   OMIT".ansi(:cyan), unit.to_s, unit.aspect]
    end

    #
    def pass(unit)
      data = ["PASS".ansi(:green), timer, clock, unit.name.ansi(:bold), unit.aspect]
      puts LAYOUT % data
    end

    #
    def fail(unit, exception)
      data = [timer, clock, "FAIL".ansi(:red), unit.name.ansi(:bold), unit.aspect]
      puts LAYOUT % data
      #puts
      #puts "        FAIL #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def error(unit, exception)
      data = [timer, clock, "FAIL".ansi(:red, :bold), unit.name.ansi(:bold), unit.aspect]
      puts LAYOUT % data
      #puts
      #puts "        ERROR #{exception.class}"
      #puts "        #{exception}"
      #puts "        " + exception.backtrace.join("\n        ")
      #puts
    end

    #
    def pending(unit, exception)
      data = [timer, clock, "PENDING".ansi(:yellow), unit.name.ansi(:bold), unit.aspect]
      puts LAYOUT % data
    end

    #
    def finish_suite(suite)
      puts

      unless record[:fail].empty?
        puts "FAILURES:\n\n"
        record[:fail].each do |unit, exception|
          puts "    #{unit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless record[:error].empty?
        puts "ERRORS:\n\n"
        record[:error].each do |unit, exception|
          puts "    #{unit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      #unless record[:pending].empty?
      #  puts "PENDING:\n\n"
      #  record[:pending].each do |unit, exception|
      #    puts "    #{unit}"
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

