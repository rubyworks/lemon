require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Outline Reporter
  class Outline < Abstract

    #
    def start_case(test_case)
      puts "* #{test_case.target}".ansi(:bold)
    end

    #
    def context(context)
      if context
        if context.to_s.empty?
          puts "  * general context"
        else
          puts "  * #{context}"
        end
      else
        puts "  * general context"
      end
    end

    #
    def start_unit(unit)
      instance = unit.instance
      if @context != context
        @context = context
        context(context)
      end
    end

    #
    def pass(unit)
      puts "    * #{unit.name} #{unit.aspect}".ansi(:green)
    end

    #
    def fail(unit, exception)
      puts "    * #{unit.name} #{unit.aspect} (FAIL)".ansi(:red)
    end

    #
    def error(unit, exception)
      puts "    * #{unit.name} #{unit.aspect} (ERROR)".ansi(:red)
    end

    #
    def omit(unit)
      puts "    * #{unit.name} #{unit.aspect} (OMIT)".ansi(:cyan)
    end

    #
    def pending(unit, exception)
      puts "    * #{unit.name} #{unit.aspect} (PENDING)".ansi(:yellow)
      #puts
      #puts "        PENDING #{exception.backtrace[0]}"
      #puts
    end

    #
    def finish_suite(suite)
      puts

      unless record[:fail].empty?
        puts "FAILURES:\n\n"
        record[:fail].each do |test_unit, exception|
          puts "    #{test_unit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless record[:error].empty?
        puts "ERRORS:\n\n"
        record[:error].each do |test_unit, exception|
          puts "    #{test_unit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      #unless record[:pending].empty?
      #  puts "PENDING:\n\n"
      #  record[:pending].each do |test_unit, exception|
      #    puts "    #{test_unit}"
      #  end
      #end

      #unless uncovered.empty?
      #  puts "UNCOVERED:\n\n"
      #  unc = uncovered.map do |test_unit|
      #    yellow("* " +test_unit.join('#'))
      #  end.join("\n")
      #  puts unc
      #  puts
      #end

      #unless undefined.empty?
      #  puts "UNDEFINED:\n\n"
      #  unc = undefined.map do |test_unit|
      #    yellow("* " + test_unit.join('#'))
      #  end.join("\n")
      #  puts unc
      #  puts
      #end

      puts tally
    end

  end

end

