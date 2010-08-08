require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # Simple Dot-Progress Reporter
  class Dotprogress < Abstract

    def omit(unit)
      print "x"; $stdout.flush
    end

    def pass(unit)
      print "."; $stdout.flush
    end

    def fail(unit, exception)
      print "F"
    end

    def error(unit, exception)
      print "E"
    end

    def pending(unit, exception)
      print "P"
    end

    def finish_suite(suite)
      puts; puts

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

      unless pendings.empty?
        puts "PENDING:\n\n"
        pendings.each do |testunit, exception|
          puts "    #{testunit}"
        end
        puts
      end

      puts tally
    end

  end

end

