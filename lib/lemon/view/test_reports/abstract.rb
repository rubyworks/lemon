module Lemon::TestReports

  # Test Reporter Base Class
  class Abstract

    require 'ansi/code'

    #
    def self.inherited(base)
      registry << base
    end

    #
    def self.registry
      @registry ||= []
    end

    #
    def initialize(runner)
      @runner = runner
      @source = {}
    end

    #
    attr :runner

    #
    def start_suite(suite)
    end

    #
    def start_case(instance)
    end

    #
    #def instance(instance)
    #end

    #
    def start_unit(unit)
    end

    # Report an omitted unit test.
    def omit(unit)
    end

    #
    def pass(unit)
    end

    #
    def fail(unit, exception)
    end

    #
    def error(unit, exception)
    end

    #
    def finish_unit(testunit)
    end

    #
    def finish_case(instance)
    end

    #
    def finish_suite(suite)
    end

    private

    def record ; runner.record ; end

    # Is coverage information requested?
    #def cover? ; runner.cover? ; end

    #
    def total
      %w{pending pass fail error omit}.inject(0){ |s,r| s += record[r.to_sym].size; s }
    end

    #
    def tally
      sizes = %w{pending fail error omit pass}.map{ |r| record[r.to_sym].size }
      data  = [total] + sizes
      s = "%s tests: %s pending, %s fail, %s err, %s omit, %s pass " % data
      #s += "(#{uncovered_units.size} uncovered, #{undefined_units.size} undefined)" if cover?
      s
    end

    #FILE_SEPARATOR = Regexp.escape(File::SEPARATOR)

    #
    INTERNALS = /(lib|bin)[\\\/]lemon/

    # Clean the backtrace of any reference to ko/ paths and code.
    def clean_backtrace(backtrace)
      trace = backtrace.reject{ |bt| bt =~ INTERNALS }
      trace.map do |bt| 
        if i = bt.index(':in')
          bt[0...i]
        else
          bt
        end
      end
    end

    # Have to thank Suraj N. Kurapati for the crux of this code.
    def code_snippet(exception, bredth=3)
      backtrace = exception.backtrace.reject{ |bt| bt =~ INTERNALS }
      backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i

      source = source(source_file)
      
      radius = bredth # number of surrounding lines to show
      region = [source_line - radius, 1].max ..
               [source_line + radius, source.length].min

      # ensure proper alignment by zero-padding line numbers
      format = " %2s %0#{region.last.to_s.length}d %s"

      pretty = region.map do |n|
        format % [('=>' if n == source_line), n, source[n-1].chomp]
      end #.unshift "[#{region.inspect}] in #{source_file}"

      pretty
    end

=begin
    #
    def code_snippet_hash(exception, bredth=3)
      backtrace = filtered_backtrace(exception)

      backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i

      source = source(source_file)
      
      radius = bredth # number of surrounding lines to show
      region = [source_line - radius, 1].max ..
               [source_line + radius, source.length].min

      # ensure proper alignment by zero-padding line numbers
      format = " %2s %0#{region.last.to_s.length}d %s"

      hash = {}
      region.each do |n|
        hash[n] = source[n-1].chomp
      end
      hash
    end
=end

    #
    def code_snippet_array(exception, bredth=3)
      backtrace = filtered_backtrace(exception)
      backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i
    
      source = source(source_file)
      
      radius = bredth # number of surrounding lines to show
      region = [source_line - radius, 1].max ..
               [source_line + radius, source.length].min
    
      # ensure proper alignment by zero-padding line numbers
      #format = " %2s %0#{region.last.to_s.length}d %s"
    
      region.map do |n|
        source[n-1].chomp
      end
    end

    #
    def code_snippet_omap(exception, bredth=3)
      backtrace = filtered_backtrace(exception)
      backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i

      source = source(source_file)
      
      radius = bredth # number of surrounding lines to show
      region = [source_line - radius, 1].max ..
               [source_line + radius, source.length].min

      # ensure proper alignment by zero-padding line numbers
      #format = " %2s %0#{region.last.to_s.length}d %s"

      a = []
      region.each do |n|
        a << {n=> source[n-1].chomp}
      end
      a
    end

    # TODO: improve
    def code_line(exception)
      code_snippet_array(exception, 0).first.strip
    end

    #
    def source(file)
      @source[file] ||= (
        File.readlines(file)
      )
    end

    # TODO: Show more of the file name than just the basename.
    def file_and_line(exception)
      line = exception.backtrace[0]
      return "" unless line
      i = line.rindex(':in')
      line = i ? line[0...i] : line
      File.basename(line)
    end

    #
    def file_and_line_array(exception)
      case exception
      when Exception
        line = exception.backtrace[0]
      else
        line = exception[0] # backtrace
      end
      return ["", 0] unless line
      i = line.rindex(':in')
      line = i ? line[0...i] : line
      f, l = File.basename(line).split(':')
      return [f, l.to_i]
    end
   

    def file(exception)
      file_and_line_array(exception).first
    end

    def line(exception)
      file_and_line_array(exception).last
    end

    #
    def filtered_backtrace(exception)
      case exception
      when Exception
        backtrace = exception.backtrace
      else
        backtrace = exception
      end
      backtrace.reject{ |bt| bt =~ INTERNALS }
    end

  end

end
