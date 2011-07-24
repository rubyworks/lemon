module Lemon::TestReports

  # Test Reporter Base Class
  class Abstract

    require 'ansi/core'

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
      @start_time = Time.now
    end

    #
    def start_case(instance)
    end

    #
    def start_test(test)
    end

    #
    def test(test)
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
    def finish_test(test)
    end

    #
    def finish_case(instance)
    end

    #
    def finish_suite(suite)
    end

    private

    def record
      runner.record
    end

    # Is coverage information requested?
    #def cover? ; runner.cover? ; end

    #
    def total
      %w{pending pass fail error omit}.inject(0){ |s,r| s += record[r.to_sym].size; s }
    end

    #
    def tally
      sizes = %w{fail error pending omit pass}.map{ |r| record[r.to_sym].size }
      data  = [total] + sizes
      s = "%s tests: %s fail, %s err, %s todo - %s omit, %s pass " % data
      #s += "(#{uncovered_units.size} uncovered, #{undefined_units.size} undefined)" if cover?
      s
    end

    EXCLUDE_PATH = File.expand_path(File.join(__FILE__, '..', '..', '..'))
    EXCLUDE      = Regexp.new(Regexp.escape(EXCLUDE_PATH))

    # Remove reference to lemon library from backtrace.
    #
    # @param [Exception] exception
    #   The error that was rasied.
    #
    #--
    # TODO: Matching `bin/lemon` is not robust.
    #++
    def clean_backtrace(exception)
      trace = (Exception === exception ? exception.backtrace : exception)
      trace = trace.reject{ |t| t =~ /bin\/lemon/ }
      trace = trace.reject{ |t| t =~ EXCLUDE }
      #trace = trace.map do |t|
      #  i = t.index(':in')
      #  i ? t[0...i] : t
      #end
      #if trace.empty?
      #  exception
      #else
      #  exception.set_backtrace(trace) if Exception === exception
      #  exception
      #end
      trace
    end

    # Have to thank Suraj N. Kurapati for the crux of this code.
    def code_snippet(exception, bredth=3)
      file, line, code, range = code_snippet_parts(exception, bredth)

      # ensure proper alignment by zero-padding line numbers
      format = " %2s %0#{range.last.to_s.length}d %s"

      range.map do |n|
        format % [('=>' if n == line), n, code[n-1].chomp]
      end #.unshift "[#{region.inspect}] in #{source_file}"
    end

    #
    def code_snippet_array(exception, bredth=3)
      file, line, code, range = code_snippet_parts(exception, bredth)
      range.map do |n|
        code[n-1].chomp
      end
    end

    #
    def code_snippet_omap(exception, bredth=3)
      file, line, code, range = code_snippet_parts(exception, bredth)
      a = []
      range.each do |n|
        a << {n => code[n-1].chomp}
      end
      a
    end

    # TODO: improve
    def code_line(exception)
      code_snippet_array(exception, 0).first.strip
    end

    #
    def code_snippet_parts(exception, bredth=3)
      backtrace = clean_backtrace(exception)
      backtrace.first =~ /(.+?):(\d+(?=:|\z))/ or return ""
      source_file, source_line = $1, $2.to_i

      source = source_code(source_file)
      
      radius = bredth # number of surrounding lines to show
      region = [source_line - radius, 1].max ..
               [source_line + radius, source.length].min

      return source_file, source_line, source, region
    end

    #
    def source_code(file)
      @source[file] ||= (
        File.readlines(file)
      )
    end

    # TODO: Show more of the file name than just the basename.
    def file_and_line(exception)
      line = clean_backtrace(exception)[0]
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

  end

end
