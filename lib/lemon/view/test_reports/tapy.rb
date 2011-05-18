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
      @n = suite.testcases.inject(0){ |c, tc| c = c + tc.size; c }
      h = {
        'type'  => "header",
        'count' => @n,
        'range' => "1..#{@n}"
      }
      puts h.to_yaml
    end

    #
    def start_unit(unit)
      @i += 1
    end

    #
    def pass(unit, backtrace=nil)
      #puts "ok #{@i} - #{unit.description}"
      backtrace = unit.caller
      h = {
        'type'        => 'test',
        'status'      => 'pass',
        'file'        => file(backtrace),
        'line'        => line(backtrace),
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        'source'      => code_snippet_array(backtrace, 0).first.strip,
        'snippet'     => code_snippet_hash(backtrace, 3),
        'message'      => unit.to_s
      }
      puts h.to_yaml
    end

    #
    def fail(unit, exception)
      #puts "not ok #{@i} - #{unit.description}"
      #puts "  FAIL #{exception.backtrace[0]}"
      #puts "  #{exception}"
      h = {
        'type'        => 'test',
        'status'      => 'fail',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        'source'      => code_snippet_array(exception, 0).first.strip,
        'snippet'     => code_snippet_hash(exception, 3),
        'message'     => exception.message
        #'trace'       => exception.backtrace
      }
      puts h.to_yaml
    end

    #
    def error(unit, exception)
      #puts "not ok #{@i} - #{unit.description}"
      #puts "  ERROR #{exception.class}"
      #puts "  #{exception}"
      #puts "  " + exception.backtrace.join("\n        ")
      h = {
        'type'        => 'test',
        'status'      => 'error',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        'source'      => code_snippet(exception, 0).first.strip,
        'snippet'     => code_snippet(exception, 3),
        'message'     => exception.message,
        'trace'       => exception.backtrace
      }
      puts h.to_yaml
    end

    #
    def pending(unit, exception)
      #puts "not ok #{@i} - #{unit.description}"
      #puts "  PENDING"
      #puts "  #{exception.backtrace[1]}"
      h = {
        'type'        => 'test',
        'status'      => 'pending',
        'file'        => file(exception),
        'line'        => line(exception),
        'description' => unit.description,
        'source'      => code_snippet(exception, 0).first.strip,
        'snippet'     => code_snippet(exception, 3),
        'message'     => exception.message
        #'trace'       => exception.backtrace
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
          'omit'    => record[:omit].size,
          'pending' => record[:pending].size # TODO: rename to `hold`?
        }
      }
      puts h.to_yaml
      puts "..."
    end
  end

end

