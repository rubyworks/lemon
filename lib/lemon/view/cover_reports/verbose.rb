require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Verbose < Abstract

    #
    def render

      unless covered_units.empty?
        puts "\nCovered Cases: "
        covered_units.map do |unit|
          puts unit_line(unit, :green)
        end
      end

      unless uncovered_units.empty?
        puts "\nUncovered Units: "
        uncovered_units.map do |unit|
          puts unit_line(unit, :yellow)
        end
      end

      unless undefined_units.empty?
        puts "\nUndefined Units: "
        undefined_units.map do |unit|
          puts unit_line(unit, :red)
        end
      end

      unless uncovered_cases.empty?
        puts "\nUncovered Cases: "
        uncovered_cases.map do |mod|
          puts "* " + mod.name.to_s.ansi(:yellow)
        end
      end

      puts
      puts tally
    end

    #
    def unit_line(unit, color)
      data = [unit.to_s.ansi(color), unit.access.to_s, unit.function? ? 'function' : 'instance method']
      "* %s  %s %s" % data
    end

  end

end

