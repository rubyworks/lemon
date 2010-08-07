require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Verbose < Abstract

    #
    def render

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

      puts
      puts tally
    end

  end

end

