require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Outline < Abstract

    #
    def render

      unless uncovered_cases.empty?
        puts "\nUncovered Cases:"
        uncovered_cases.map do |mod|
          puts "* #{yellow(mod.name)}"
        end
      end

      unless covered_units.empty?
        puts "\nCovered Units:"
        covered_units.map do |unit|
          puts "* #{green(unit.to_s)}"
        end.join(", ")
      end

      unless uncovered_units.empty?
        puts "\nUncovered Units:"
        uncovered_units.map do |unit|
          puts "* #{yellow(unit.to_s)}"
        end
      end

      #unless uncovered.empty?
      #  unc = uncovered.map do |unit|
      #    yellow(unit)
      #  end.join(", ")
      #  puts "\nUncovered: " + unc
      #end

      unless undefined_units.empty?
        puts "\nUndefined Units:"
        unc = undefined_units.map do |unit|
          puts "* #{red(unit.to_s)}"
        end
      end

      puts
      puts tally
    end

  end

end

