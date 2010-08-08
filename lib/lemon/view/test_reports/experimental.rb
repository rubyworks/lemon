require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Other Reporter
  class Other < Abstract

    #
    def start_suite(suite)
      timer_reset
    end

    #
    def start_case(tc)
      puts
      puts tc.to_s.ansi(:bold)
    end

    #
    #def report_instance(instance)
    #  puts
    #  puts instance #"== #{concern.description}\n\n" unless concern.description.empty?
    #  #timer_reset
    #end

    #
    def omit(unit)
      puts "  %s  %s %s" % ["   OMIT".ansi(:cyan), unit.name, unit.aspect]
    end

    #
    def start_unit(unit)
       instance = unit.instance
       if @instance != instance
         @instance = instance
         puts
         puts "  #{instance}"
         puts
       end
    end

    #
    def pass(unit)
      puts "  %s  %s %s" % ["   PASS".ansi(:green), unit.name, unit.aspect]
    end

    #
    def fail(unit, exception)
      puts "  %s  %s %s" % ["   FAIL".ansi(:red), unit.name, unit.aspect]
      puts
      puts "        FAIL #{exception.backtrace[0]}"
      puts "        #{exception}"
      puts
    end

    #
    def error(unit, exception)
      puts "  %s  %s %s" % ["  ERROR".ansi(:red), unit.name, unit.aspect]
      puts
      puts "        ERROR #{exception.class}"
      puts "        #{exception}"
      puts "        " + exception.backtrace.join("\n        ")
      puts
    end

    #
    def pending(unit, exception)
      puts "  %s  %s %s" % ["PENDING".ansi(:yellow), unit.name, unit.aspect]
    end

    #
    def finish_suite(suite)
      #puts

      #unless failures.empty?
      #  puts "FAILURES:\n\n"
      #  failures.each do |unit, exception|
      #    puts "    #{unit}"
      #    puts "    #{exception}"
      #    puts "    #{exception.backtrace[0]}"
      #    puts
      #  end
      #end

      #unless errors.empty?
      #  puts "ERRORS:\n\n"
      #  errors.each do |unit, exception|
      #    puts "    #{unit}"
      #    puts "    #{exception}"
      #    puts "    #{exception.backtrace[0]}"
      #    puts
      #  end
      #end

      #unless pendings.empty?
      #  puts "PENDING:\n\n"
      #  pendings.each do |unit, exception|
      #    puts "    #{unit}"
      #  end
      #  puts
      #end

      puts
      puts tally
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

