require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  #--
  #returned: true
  #expected: true
  #source: ok 1, 2
  #snippet:
  #  44: ok 0,0
  #  45: ok 1,2
  #  46: ok 2,4
  #++

  # TAP-Y Reporter
  #
  # TODO: Lemon needs some improvements in order to supply all the
  # information TAP-Y supports. In particular, `file` and `line` information.
  class Tapy < Abstract

    #
    def start_suite(suite)
      require 'yaml'

      @start = Time.now
      @i = 0
      @n = suite.test_cases.inject(0){ |c, tc| c = c + tc.size; c }
      h = {
        'type'  => "header",
        'count' => @n,
        'range' => "1..#{@n}"
      }
      puts h.to_yaml
    end

    #
    def start_case(tcase)
      h = {
        'type' => 'case',
        'description' => "#{tcase.to_s} #{tcase.aspect}".strip
      }
      puts h.to_yaml
    end

    #
    def start_unit(unit)
      @i += 1
    end

    #
    def pass(unit) #, backtrace=nil)
      h = {
        'type'        => 'test',
        'status'      => 'pass',
        'file'        => unit.file,
        'line'        => unit.line,
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        'source'      => code_line(unit.caller),
        'snippet'     => code_snippet_omap(unit.caller, 3),
        'message'     => unit.to_s,
        'time'        => Time.now - @start
      }
      puts h.to_yaml
    end

    #
    def fail(unit, exception)
      h = {
        'type'        => 'test',
        'status'      => 'fail',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        'source'      => code_line(exception),
        'snippet'     => code_snippet_omap(exception, 3),
        'message'     => exception.message,
        'time'        => Time.now - @start
        #'backtrace'   => exception.backtrace
      }
      puts h.to_yaml
    end

    #
    def error(unit, exception)
      h = {
        'type'        => 'test',
        'status'      => 'error',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        'source'      => code_line(exception),
        'snippet'     => code_snippet_omap(exception, 3),
        'message'     => exception.message,
        'backtrace'   => exception.backtrace,
        'time'        => Time.now - @start
      }
      puts h.to_yaml
    end

    #
    def pending(unit, exception)
      h = {
        'type'        => 'test',
        'status'      => 'pending',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        'source'      => code_line(exception),
        'snippet'     => code_snippet_omap(exception, 3),
        'message'     => exception.message,
        'time'        => Time.now - @start
        #'backtrace'   => exception.backtrace
      }
      puts h.to_yaml
    end

    #
    def finish_suite(suite)
      h = {
        'type'  => 'footer',
        'time'  => Time.now - @start,
        'count' => @n, #total
        'tally' => {
          'pass'    => record[:pass].size,
          'fail'    => record[:fail].size,
          'error'   => record[:error].size,
          'omit'    => record[:omit].size,
          'pending' => record[:pending].size # TODO: rename to `hold`?
        }
      }
      puts h.to_yaml
      puts "..."
    end
  end

end

