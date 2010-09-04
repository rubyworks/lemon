require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Summary Reporter
  class Summary < Abstract

    #
    def start_suite(suite)
      timer_reset
    end

    #
    #def start_case(tc)
    #  puts
    #  puts tc.to_s.ansi(:bold)
    #end

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
    #def start_unit(unit)
    #   context = unit.context
    #   if @instance != context
    #     @context = context
    #     puts
    #     puts "  #{context}"
    #     puts
    #   end
    #end

    #
    def omit(unit)
      puts "  %s  %s %s" % ["   OMIT".ansi(:cyan), unit.to_s.ansi(:bold), unit.aspect]
    end

    #
    def pass(unit)
      puts "  %s  %s %s" % ["   PASS".ansi(:green), unit.to_s.ansi(:bold), unit.aspect]
    end

    #
    def fail(unit, exception)
      puts "  %s  %s %s" % ["   FAIL".ansi(:red), unit.to_s.ansi(:bold), unit.aspect]
      #puts
      #puts "        FAIL #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def error(unit, exception)
      puts "  %s  %s %s" % ["  ERROR".ansi(:red), unit.to_s.ansi(:bold), unit.aspect]
      #puts
      #puts "        ERROR #{exception.class}"
      #puts "        #{exception}"
      #puts "        " + exception.backtrace.join("\n        ")
      #puts
    end

    #
    def pending(unit, exception)
      puts "  %s  %s %s" % ["PENDING".ansi(:yellow), unit.to_s.ansi(:bold), unit.aspect]
    end

    #
    def finish_suite(suite)
      puts

      unless record[:pending].empty?
        puts "PENDING:\n\n"
        record[:pending].each do |unit, exception|
          puts "    #{unit}"
          puts "    #{file_and_line(exception)}"
          puts
        end
      end

      unless record[:fail].empty?
        puts "FAILURES:\n\n"
        record[:fail].each do |unit, exception|
          puts "    #{unit}"
          puts "    #{file_and_line(exception)}"
          puts "    #{exception}"
          puts code_snippet(exception)
          #puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless record[:error].empty?
        puts "ERRORS:\n\n"
        record[:error].each do |unit, exception|
          puts "    #{unit}"
          puts "    #{file_and_line(exception)}"
          puts "    #{exception}"
          puts code_snippet(exception)
          #puts "    #{exception.backtrace[0]}"
          puts
        end
      end

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

