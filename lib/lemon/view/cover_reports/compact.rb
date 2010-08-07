require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Compact < Abstract

    #
    def render

      unless uncovered_cases.empty?
        puts "\nUncovered Cases: "
        puts uncovered_cases.map{ |m| "#{yellow(m.name)}" }.join(', ')
      end

      unless covered_units.empty?
        puts "\nCovered Units: "
        puts covered_units.map{ |u| "#{green(u.to_s)}" }.join(', ')
      end

      unless uncovered_units.empty?
        puts "\nUncovered Units: "
        puts uncovered_units.map{ |u| "#{yellow(u.to_s)}" }.join(', ')
      end

      unless undefined_units.empty?
        puts "\nUndefined Units:"
        puts undefined_units.map{ |u| "#{red(u.to_s)}" }.join(', ')
      end

      puts
      puts tally
    end

  end

end

