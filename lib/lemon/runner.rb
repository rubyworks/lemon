require 'ae'
require 'ae/expect'
require 'ae/should'

require 'lemon/kernel'

require 'lemon/suite'
require 'lemon/case'
require 'lemon/unit'

require 'lemon/reporter'

module Lemon

  #
  class Runner
    attr :suite

    attr :successes
    attr :failures
    attr :errors

    #
    def initialize(suite)
      @suite    = suite

      @successes = []
      @failures  = []
      @errors    = []
    end

    #
    def run
      reporter.report_start(suite)
      @suite.each do |testcase|
        testcase.each do |testunit|
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
          afters = testcase.after_clauses.each do |match, block|
            block.call(testunit) if match === testunit.test_concern
          end
        end
      end
      reporter.report_finish(successes, failures, errors)
    end

    #
    def reporter
      @reporter ||= Reporter.new
    end

  end

end

