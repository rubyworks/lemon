module Lemon
module Rind

  class Report

    #
    def initialize(analysis, options={})
      @chart   = analysis.chart
      @options = options
    end

    #
    def options
      @options
    end

    #
    def chart
      @chart
    end

    #
    def render
      require 'erb'
      rhtml = File.read(File.dirname(__FILE__) + '/report.rhtml')
      ERB.new(rhtml).result(binding)
    end

    #
    def save(logpath)
      require 'fileutils'
      dir  = File.join(logpath, 'lemon')
      file = File.join(dir, 'index.html')
      FileUtils.mkdir_p(dir)
      File.open(file, 'w'){ |w| w << render }
    end

    #
    def display(format=nil)
      case options[:format]
      when 'tap'
        display_tap
      else
        display_color
      end
    end

    #
    def display_color
      require 'ansi'
      i = 0
      chart.sort.each do |(unit, yes)|
        i += 1
        if yes
          puts "* " + unit.to_s.ansi(:green)
        else
          puts "* " + unit.to_s.ansi(:red)
        end
      end
    end

    #
    def display_tap
      i = 0
      chart.sort.each do |(unit, yes)|
        i += 1
        if yes
          puts "ok #{i} - " + unit.to_s
        else
          puts "not ok #{i} - " + unit.to_s
        end
      end
    end

  end


end
end

