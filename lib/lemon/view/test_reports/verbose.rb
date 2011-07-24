require 'lemon/view/test_reports/abstract'
require 'facets/string/tabto'

module Lemon::TestReports

  # Timed Reporter
  class Verbose < Abstract

    LAYOUT = "  %-12s  %11s  %11s    %s"

    #
    def start_suite(suite)
      @start = Time.now
      @tab   = 0
      @start_test_cache = {}

      timer_reset
    end

    #
    def start_case(tc)
      tabs tc.to_s.ansi(:bold)
      @tab += 2
    end

    #
    def start_test(test)
       if test.subject
         @start_test_cache[test.subject] ||= (
           puts "#{test.subject}".tabto(@tab)
           true
         )
       end
       timer_reset
    end

    #
    def omit(test)
      data = ["OMIT".ansi(:cyan), timer, clock, test.to_s.ansi(:bold)]
      tabs LAYOUT % data
      #puts "  %s  %s  %s" % ["   OMIT".ansi(:cyan), test.to_s, test.aspect]
      @_last = :test
    end

    #
    def pass(test)
      data = ["PASS".ansi(:green), timer, clock, test.to_s.ansi(:bold)]
      tabs LAYOUT % data
    end

    #
    def fail(test, exception)
      data = ["FAIL".ansi(:red), timer, clock, test.to_s.ansi(:bold)]
      tabs LAYOUT % data
      #puts
      #puts "        FAIL #{exception.backtrace[0]}"
      #puts "        #{exception}"
      #puts
    end

    #
    def error(test, exception)
      data = ["ERROR".ansi(:red, :bold), timer, clock, test.to_s.ansi(:bold)]
      tabs LAYOUT % data
      #puts
      #puts "        ERROR #{exception.class}"
      #puts "        #{exception}"
      #puts "        " + exception.backtrace.join("\n        ")
      #puts
    end

    #
    def pending(test, exception)
      data = ["PENDING".ansi(:yellow), timer, clock, test.to_s.ansi(:bold)]
      tabs LAYOUT % data
    end

    #
    def finish_test(test)
      #@_last = :test
    end

    #
    def finish_case(tcase)
      #@_last = :test
      @tab -= 2
    end

    #
    def finish_suite(suite)
      puts

      unless record[:omit].empty?
        puts "OMITTED:\n\n"
        puts record[:omit].map{ |u| u.to_s }.sort.join('  ')
        puts
      end

      unless record[:pending].empty?
        puts "PENDING:\n\n"
        record[:pending].each do |test, exception|
          puts "#{test}".tabto(4)
          puts "#{file_and_line(exception)}".tabto(4)
          puts
        end
      end

      unless record[:fail].empty?
        puts "FAILURES:\n\n"
        record[:fail].each do |test, exception|
          puts "#{test}".ansi(:bold).tabto(4)
          puts "#{file_and_line(exception)}".ansi(:red).tabto(4)
          puts "#{exception}".ansi(:red).tabto(4)
          puts code_snippet(exception).tabto(2)
          #puts "    #{exception.backtrace[0]}"
          puts
        end
      end

      unless record[:error].empty?
        puts "ERRORS:\n\n"
        record[:error].each do |test, exception|
          trace = clean_backtrace(exception)[1..-1]

          puts "#{test}".ansi(:bold).tabto(4)
          puts "#{exception.class} @ #{file_and_line(exception)}".ansi(:red).tabto(4)
          puts "#{exception}".ansi(:red).tabto(4)
          puts code_snippet(exception).tabto(2)
          puts trace.join("\n").tabto(4) unless trace.empty?
          puts
        end
      end

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

    #
    def tabs(str=nil)
      if str
        puts(str.tabto(@tab))
      else
        puts
      end
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

