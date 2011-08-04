require 'lemon/coverage/formats/abstract'

module Lemon::CoverReports

  class Compact < Abstract

    #
    def render

      unless covered_units.empty?
        puts "\nCovered Units: "
        puts covered_units.map{ |u| u.to_s.ansi(:green) }.sort.join(', ')
      end

      unless undefined_units.empty?
        puts "\nOvercovered Units:"
        puts undefined_units.map{ |u| u.to_s.ansi(:cyan) }.sort.join(', ')
      end

      unless uncovered_units.empty?
        puts "\nUncovered Units: "
        puts uncovered_units.map{ |u| u.to_s.ansi(:yellow) }.sort.join(', ')
      end

      unless uncovered_cases.empty?
        puts "\nUncovered Cases: "
        puts uncovered_cases.map{ |m| m.name.ansi(:red) }.sort.join(', ')
      end

      puts
      puts tally
    end

  end

end

