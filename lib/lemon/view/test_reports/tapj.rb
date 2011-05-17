require 'lemon/view/test_reports/abstract'

module Lemon::TestReports

  # TAP-J Reporter
  #
  # TODO: Lemon needs some improvements in order to supply all the
  # information TAP-J supports. In particular, `file` and `line` information.
  class Tapj < Abstract

    #
    def start_suite(suite)
      require 'json'

      @start = Time.now
      @i = 0
      @n = suite.testcases.inject(0){ |c, tc| c = c + tc.size; c }
      h = {
        'type'  => "header",
        'count' => @n,
        'range' => "1..#{@n}"
      }
      puts h.to_json
    end

    #
    def start_unit(unit)
      @i += 1
    end

    #
    def pass(unit)
      #puts "ok #{@i} - #{unit.description}"
      h = {
        'type'        => 'test',
        'status'      => 'pass',
        #'file'        => unit.file,
        #'line'        => unit.line,
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        #'source'      => '',
        #'snippet'     => {},
      }
      puts h.to_json
    end

    #
    def fail(unit, exception)
      #puts "not ok #{@i} - #{unit.description}"
      #puts "  FAIL #{exception.backtrace[0]}"
      #puts "  #{exception}"
      h = {
        'type'        => 'test',
        'status'      => 'fail',
        #'file'        => unit.file,
        #'line'        => unit.line,
        'description' => unit.description,
        #'returned'    => '',
        #'expected'    => '',
        'source'      => code_snippet(exception, 1),
        'snippet'     => code_snippet_hash(exception, 3),
        'message'     => exception.message
        #'trace'       => exception.backtrace
      }
      puts h.to_json
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
        #'file'        => unit.file,
        #'line'        => unit.line,
        'description' => unit.description,
        'source'      => code_snippet(exception, 1),
        'snippet'     => code_snippet_hash(exception, 3),
        'message'     => exception.message,
        'trace'       => exception.backtrace
      }
      puts h.to_json
    end

    #
    def pending(unit, exception)
      #puts "not ok #{@i} - #{unit.description}"
      #puts "  PENDING"
      #puts "  #{exception.backtrace[1]}"
      h = {
        'type'        => 'test',
        'status'      => 'pending',
        #'file'        => unit.file,
        #'line'        => unit.line,
        'description' => unit.description,
        'source'      => code_snippet(exception, 1),
        'snippet'     => code_snippet_hash(exception, 3),
        'message'     => exception.message
        #'trace'       => exception.backtrace
      }
      puts h.to_json
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
      puts h.to_json
    end
  end

end

