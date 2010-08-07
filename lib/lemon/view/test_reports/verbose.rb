require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Verbose Reporter
  class Verbose < Abstract

    #
    def report_start(suite)
      timer_reset
      puts
    end

    #
    def report_instance(instance)
      #puts
      #puts "== #{concern.description}\n\n" unless concern.description.empty?
      #timer_reset
    end

    #
    def report_success(testunit)
      puts "  %s  %s  %s" % [green("   PASS"), testunit.to_s, testunit.description]
    end

    #
    def report_failure(testunit, exception)
      puts "  %s  %s  %s" % [red("   FAIL"), testunit.to_s, testunit.description]
      puts
      puts "        FAIL #{exception.backtrace[0]}"
      puts "        #{exception}"
      puts
    end

    #
    def report_error(testunit, exception)
      puts "  %s    %s  %s" % [red("  ERROR"), testunit.to_s, testunit.description]
      puts
      puts "        ERROR #{exception.class}"
      puts "        #{exception}"
      puts "        " + exception.backtrace.join("\n        ")
      puts
    end

    #
    def report_pending(testunit, exception)
      puts "  %s  %s  %s" % [yellow("PENDING"), testunit.to_s, testunit.description]
      #puts
      #puts "        PENDING #{exception.backtrace[1]}"
      #puts
    end

    #
    def report_finish(suite)
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

