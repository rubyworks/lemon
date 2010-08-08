require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Outline Reporter
  class Outline < Abstract

    #
    def start_case(testcase)
      puts "* #{testcase.target}".ansi(:bold)
    end

    #
    def instance(instance)
      if instance
        if instance.to_s.empty?
          puts "  * general %s" % (instance.meta? ? "singleton" : "instance")
        else
          puts "  * #{instance}"
        end
      else
        puts "  * general case instance"
      end
    end

    #
    def start_unit(unit)
      instance = unit.instance
      if @instance != instance
        @instance = instance
        instance(instance)
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
        record[:fail].each do |testunit, exception|
          puts "    #{testunit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless record[:error].empty?
        puts "ERRORS:\n\n"
        record[:error].each do |testunit, exception|
          puts "    #{testunit}"
          puts "    #{exception}"
          puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      #unless record[:pending].empty?
      #  puts "PENDING:\n\n"
      #  record[:pending].each do |testunit, exception|
      #    puts "    #{testunit}"
      #  end
      #end

      #unless uncovered.empty?
      #  puts "UNCOVERED:\n\n"
      #  unc = uncovered.map do |testunit|
      #    yellow("* " +testunit.join('#'))
      #  end.join("\n")
      #  puts unc
      #  puts
      #end

      #unless undefined.empty?
      #  puts "UNDEFINED:\n\n"
      #  unc = undefined.map do |testunit|
      #    yellow("* " + testunit.join('#'))
      #  end.join("\n")
      #  puts unc
      #  puts
      #end

      puts tally
    end

  end

end

