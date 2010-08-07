module Lemon

  #require 'lemon/model/main'
  require 'lemon/model/test_suite'

  #
  class TestRunner

    # Test suite to run.
    attr :suite

    # Report format.
    attr :format

    # Record of successful tests.
    attr :successes

    # Record of failed tests.
    attr :failures

    # Record of errors.
    attr :errors

    # Record of pending tests.
    attr :pendings

    # New Runner.
    def initialize(suite, options={})
      @suite     = suite
      @options   = options

      @successes = []
      @failures  = []
      @errors    = []
      @pendings  = []
    end

    #
    def format
      @options[:format]
    end

    #
    #def cover?
    #  @options[:cover]
    #end

    # Namespaces option specifies the selection of test cases
    # to run. Is is an array of strings which are matched 
    # against the module/class names using #start_wtih?
    def namespaces
      @options[:namespaces] || []
    end

    # Run tests.
    def run
      #prepare
      scope = Object.new
 
      reporter.report_start(suite)

      each do |testcase|
        reporter.report_start_testcase(testcase)
        testcase.each do |step|
          case step
          when TestInstance
            reporter.report_instance(step)
          when TestUnit
            testunit = step
            reporter.report_start_testunit(testunit)
            run_pretest_procedures(testunit, scope) #, suite, testcase)
            begin
              testunit.call(scope)
              reporter.report_success(testunit)
              successes << testunit
            rescue Pending => exception
              exception = clean_backtrace(exception)
              reporter.report_pending(testunit, exception)
              pendings << [testunit, exception]
            rescue Assertion => exception
              exception = clean_backtrace(exception)
              reporter.report_failure(testunit, exception)
              failures << [testunit, exception]
            rescue Exception => exception
              exception = clean_backtrace(exception)
              reporter.report_error(testunit, exception)
              errors << [testunit, exception]
            end
            reporter.report_finish_testunit(testunit)
            run_postest_procedures(testunit, scope) #, suite, testcase)
          end
        end
        reporter.report_finish_testcase(testcase)
      end

      reporter.report_finish(suite) #(successes, failures, errors, pendings)
    end

    # Iterate over suite testcases, filtering out unselected testcases
    # if any namespaces are provided.
    def each(&block)
      if namespaces.empty?
        suite.each do |testcase|
          block.call(testcase)
        end
      else
        suite.each do |testcase|
          next unless namespaces.any?{ |n| testcase.target.name.start_with?(n) }
          block.call(testcase)
        end
      end
    end

    # All output is handled by a reporter.
    def reporter
      @reporter ||= reporter_find(format)
    end

    #
    def reporter_find(format)
      format = format ? format.to_s.downcase : 'dotprogress'
      format = reporter_list.find do |r|
        /^#{format}/ =~ r
      end
      raise "unsupported format" unless format
      require "lemon/view/test_reports/#{format}"
      reporter = Lemon::TestReports.const_get(format.capitalize)
      reporter.new(self)
    end

    #
    def reporter_list
      Dir[File.dirname(__FILE__) + '/../view/test_reports/*.rb'].map do |rb|
        File.basename(rb).chomp('.rb')
      end
    end

  private

=begin
    #
    def run_concern_procedures(concern, scope) #suite, testcase)
      tc    = concern.testcase
      suite = tc.suite
      suite.when_clauses.each do |match, block|
        if match.nil? or match === concern.to_s
          #block.call #(test_case)
          scope.instance_exec(tc, &block)
        end
      end
      tc.when_clauses.each do |match, block|
        if match.nil? or match === concern.to_s
          if match === concern.to_s
            #block.call #(test_case)
            scope.instance_exec(tc, &block)
          end
        end
      end
      concern.call(scope)
    end
=end

    # Run pre-test advice.
    def run_pretest_procedures(unit, scope) #, suite, testcase)
      suite = unit.testcase.suite
      suite.before.each do |match, block|
        if match.nil? or unit.match?(match)
          #block.call(unit)
          scope.instance_exec(unit, &block)
        end
      end
      unit.testcase.before.each do |match, block|
        if match.nil? or test_unit.match?(match)
          #block.call(testunit)
          scope.instance_exec(unit, &block)
        end
      end
    end

    # Run post-test advice.
    def run_postest_procedures(unit, scope) #, suite, testcase)
      suite = unit.testcase.suite
      unit.testcase.after.each do |match, block|
        if match.nil? or unit.match?(match)
          #block.call(unit)
          scope.instance_exec(unit, &block)
        end
      end
      suite.after.each do |match, block|
        if match.nil? or testunit.match?(match)
          #block.call(testunit)
          scope.instance_exec(unit, &block)
        end
      end
    end

    # Remove reference to lemon library from backtrace.
    def clean_backtrace(exception)
      trace = exception.backtrace.reject{ |t| t =~ /(lib|bin)\/lemon/ }
      exception.set_backtrace(trace)
      exception
    end

  end

end


=begin
    #
    def prepare
      if cover?
        coverage.canonical!
      end

      suite.load_covered_files

      if cover?
        @uncovered = calculate_uncovered
        @undefined = calculate_undefined
      end
    end
=end

