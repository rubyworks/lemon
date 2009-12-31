module Lemon

  require 'ae'
  require 'ae/expect'
  require 'ae/should'

  require 'lemon/kernel'
  require 'lemon/test/suite'
  require 'lemon/reporters'

  #
  class Runner

    # Test suite to run.
    attr :suite

    # Record of successful tests.
    attr :successes

    # Record of failed tests.
    attr :failures

    # Record of errors.
    attr :errors

    # Report format.
    attr :format

    # New Runner.
    def initialize(suite, format)
      @suite     = suite
      @format    = format
      @successes = []
      @failures  = []
      @errors    = []
    end

    # Run tests.
    def run
      reporter.report_start(suite)
      suite.each do |testcase|
        testcase.each do |concern|
          reporter.report_concern(concern)
          run_concern_procedures(concern, suite, testcase)
          concern.each do |testunit|
            run_pretest_procedures(testunit, suite, testcase)
            begin
              testunit.call
              reporter.report_success(testunit)
              successes << testunit
            rescue Assertion => exception
              reporter.report_failure(testunit, exception)
              failures << [testunit, exception]
            rescue Exception => exception
              reporter.report_error(testunit, exception)
              errors << [testunit, exception]
            end
            run_postest_procedures(testunit, suite, testcase)
          end
        end
      end
      reporter.report_finish(successes, failures, errors)
    end

    # All output is handled by a reporter.
    def reporter
      @reporter ||= Reporter.factory(format)
    end

    private

    #
    def run_concern_procedures(concern, suite, testcase)
      suite.when_clauses.each do |match, block|
        if match.nil? or match === concern.to_s
          block.call(testcase)
        end
      end
      testcase.when_clauses.each do |match, block|
        if match.nil? or match === concern.to_s
          block.call(testcase) if match === concern.to_s
        end
      end
    end

    #
    def run_pretest_procedures(testunit, suite, testcase)
      suite.before_clauses.each do |match, block|
        if match.nil? or match === testunit.aspect
          block.call(testunit)
        end
      end
      testcase.before_clauses.each do |match, block|
        if match.nil? or match === testunit.aspect
          block.call(testunit)
        end
      end
    end

    #
    def run_postest_procedures(testunit, suite, testcase)
      testcase.after_clauses.each do |match, block|
        if match.nil? or match === testunit.aspect
          block.call(testunit)
        end
      end
      suite.after_clauses.each do |match, block|
        if match.nil? or match === testunit.aspect
          block.call(testunit)
        end
      end
    end

  end

end

