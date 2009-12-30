module Lemon

  require 'ae'
  require 'ae/expect'
  require 'ae/should'

  require 'lemon/kernel'
  require 'lemon/test/suite'
  require 'lemon/reporter'

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

    # New Runner.
    def initialize(suite)
      @suite     = suite
      @successes = []
      @failures  = []
      @errors    = []
    end

    # Run tests.
    def run
      reporter.report_start(suite)
      suite.each do |testcase|
        testcase.each do |concern|
          concern.each do |testunit|
            suite.before_clauses.each do |match, block|
              block.call(testunit) if match === testunit.test_concern
            end
            testcase.before_clauses.each do |match, block|
              block.call(testunit) if match === testunit.test_concern
            end

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

            testcase.after_clauses.each do |match, block|
              block.call(testunit) if match === testunit.test_concern
            end
            suite.after_clauses.each do |match, block|
              block.call(testunit) if match === testunit.test_concern
            end
          end
        end
      end
      reporter.report_finish(successes, failures, errors)
    end

    # All output is handled by a reporter.
    def reporter
      @reporter ||= Reporter.new
    end

  end

end

