require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Outline < Abstract

    #
    def render

      unless covered_units.empty?
        puts "\nCovered Units:"
        covered_units.map do |unit|
          puts "* #{unit.to_s.ansi(:green)}"
        end.join(", ")
      end

      unless uncovered_units.empty?
        puts "\nUncovered Units:"
        uncovered_units.map do |unit|
          puts "* #{unit.to_s.ansi(:yellow)}"
        end
      end

      unless undefined_units.empty?
        puts "\nUndefined Units:"
        unc = undefined_units.map do |unit|
          puts "* #{unit.to_s.ansi(:red)}"
        end
      end

      unless uncovered_cases.empty?
        puts "\nUncovered Cases:"
        uncovered_cases.map do |mod|
          puts "* #{mod.name.ansi(:cyan)}"
        end
      end

      puts
      puts tally
    end

  end

end

