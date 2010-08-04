module Lemon::Test
module Reporter

  require 'lemon/test/reporter/abstract'

  # Outline Reporter
  class Outline < Abstract

    #
    def report_start(suite)
    end

    def report_start_testcase(testcase)
      puts "#{testcase.target}".ansi(:bold)
    end

    #
    def report_instance(instance)
      if instance
        if instance.to_s.empty?
          puts "    general %s" % (instance.meta? ? "singleton" : "instance")
        else
          puts "    #{instance}"
        end
      else
        puts "    #general case instance"
      end
    end

    #
    def report_success(testunit)
      puts green("        #{testunit}  #{testunit.aspect}")
    end

    #
    def report_failure(testunit, exception)
      puts red("        #{testunit}  #{testunit.aspect}")
    end

    #
    def report_error(testunit, exception)
      puts red("        #{testunit}  #{testunit.aspect}")
    end

    #
    def report_pending(testunit, exception)
      puts yellow("        #{testunit} (PENDING)")
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
end

