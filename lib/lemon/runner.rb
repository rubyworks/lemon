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
    def initialize(suite, format, options={})
      @suite     = suite
      @format    = format
      @options   = options

      @successes = []
      @failures  = []
      @errors    = []
      @pendings  = []
    end

    #
    def cover?
      @options[:cover]
    end

    # Namespaces option specifies the selection of test cases
    # to run. Is is an array of strings which are matched 
    # against the module/class names using #start_wtih?
    def namespaces
      @options[:namespaces] || []
    end

    # Run tests.
    def run
      prepare

      reporter.report_start(suite)

      each do |testcase|
        testcase.each do |concern|
          reporter.report_concern(concern)
          run_concern_procedures(concern, suite, testcase)
          concern.each do |testunit|
            #mark_coverage(testcase, testunit)
            run_pretest_procedures(testunit, suite, testcase)
            begin
              testunit.call
              reporter.report_success(testunit)
              successes << testunit
            rescue Pending => exception
              reporter.report_pending(testunit, exception)
              pendings << [testunit, exception]
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

      reporter.report_finish #(successes, failures, errors, pendings)
    end

    # Iterate overs suite testcases, filtering out unselected testcases
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
      @reporter ||= Reporter.factory(format, self)
    end

    #
    #def uncovered
    #  c = []
    #  @testcase_coverage.each do |testcase, testunits|
    #    testunits.each do |testunit, coverage|
    #      c << [testcase, testunit] if coverage == false
    #    end
    #  end
    #  c
    #end

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

    #
    def uncovered
      @uncovered ||= calculate_uncovered
    end

    #
    def undefined
      @undefined ||= calculate_undefined
    end

    #
    def calculate_uncovered
      uncovered_targets = []
      coverage.each do |testcase, testunits|
        testunits.each do |testunit, covered|
          uncovered_targets << [testcase, testunit] unless covered
        end
      end
      uncovered_targets
    end

    #
    def calculate_undefined
      covered_testunits = successes + (failures + errors + pendings).map{ |tu, e| tu }
      covered_targets = covered_testunits.map{ |tu| [tu.testcase.target.name, tu.target.to_s] }

      targets = []
      coverage.each do |testcase, testunits|
        testunits.each do |testunit, coverage|
          targets << [testcase, testunit]
        end
      end

      covered_targets - targets
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
      concern.call
    end

    # Run pre-test advice.
    def run_pretest_procedures(testunit, suite, testcase)
      suite.before_clauses.each do |match, block|
        if match.nil? or testunit.match?(match)
          block.call(testunit)
        end
      end
      testcase.before_clauses.each do |match, block|
        if match.nil? or testunit.match?(match)
          block.call(testunit)
        end
      end
    end

    # Run post-test advice.
    def run_postest_procedures(testunit, suite, testcase)
      testcase.after_clauses.each do |match, block|
        if match.nil? or testunit.match?(match)
          block.call(testunit)
        end
      end
      suite.after_clauses.each do |match, block|
        if match.nil? or testunit.match?(match)
          block.call(testunit)
        end
      end
    end

    #
    def coverage
      @coverage ||= Lemon::Coverage.new(suite, namespaces) #, :public => public_only?)
    end

=begin
    # TODO: I would think all this should be gained form the Coverage class.

    # TODO: options to include non-public and superclasses less Object and Kernel.
    def mark_coverage(testcase, testunit)
      testunit = testunit.target.to_sym
      profile  = testcase_profile(testcase)
      coverage = testcase_coverage(testcase)

      if profile[:public].include?(testunit) || profile[:meta_public].include?(testunit)
        coverage[testunit] = :public
      elsif profile[:private].include?(testunit) || profile[:meta_private].include?(testunit)
        coverage[testunit] = :private
      elsif profile[:protected].include?(testunit) || profile[:meta_protected].include?(testunit)
        coverage[testunit] = :protected
      else
        coverage[testunit] = nil # nil means does not exist, while false means not covered.
      end
    end

    #
    def testcase_coverage(testcase)
      target = testcase.target
      @testcase_coverage ||= {}
      @testcase_coverage[target] ||= (
        h = {}
        target.public_instance_methods(false).each{|unit| h[unit] = false }
        (target.public_methods(false) - Object.public_methods(false)).each{|unit| h[unit] = false }
        #target.private_instance_method(false)
        #target.protected_instance_method(false)
        h
      )
    end

    #
    def testcase_profile(testcase)
      target = testcase.target
      @testcase_profile ||= {}
      @testcase_profile[target] ||= {
        :public    => target.public_instance_methods(false).map{|s|s.to_sym},
        :private   => target.private_instance_methods(false).map{|s|s.to_sym},
        :protected => target.protected_instance_methods(false).map{|s|s.to_sym},
        :meta_public    => (target.public_methods(false) - Object.public_methods(false)).map{|s|s.to_sym},
        :meta_private   => (target.private_methods(false) - Object.private_methods(false)).map{|s|s.to_sym},
        :meta_protected => (target.protected_methods(false)- Object.protected_methods(false)).map{|s|s.to_sym}
      }
    end
=end

  end

end

