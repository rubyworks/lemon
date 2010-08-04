module Lemon
module Test

  require 'ae'
  require 'ae/expect'
  require 'ae/should'

  require 'lemon/aid/pry'

  require 'lemon/test/suite'
  require 'lemon/test/reporter'

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
          when Test::Instance
            reporter.report_instance(step)
          when Test::Unit
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

      reporter.report_finish #(successes, failures, errors, pendings)
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
      @reporter ||= Reporter.factory(format, self)
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
      suite.before_clauses.each do |match, block|
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
      suite.after_clauses.each do |match, block|
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
end










    #def coverage
    #  @coverage ||= Lemon::Coverage.new(suite, namespaces) #, :public => public_only?)
    #end

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

=begin
    #
    def uncovered_cases
      @uncovered_cases ||= coverage.uncovered_cases
    end

    #
    def uncovered_units
      @uncovered_units ||= coverage.uncovered_units
    end

    #
    def undefined_units
      @undefined_units ||= coverage.undefined_units
    end
=end

=begin
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
      coverage.checklist.each do |mod, meths|
        meths.each do |meth, covered|
          if !covered
            if /^::/ =~ meth.to_s
              uncovered_targets << "#{mod}#{meth}"
            else
              uncovered_targets << "#{mod}##{meth}"
            end
          end
        end
      end
      uncovered_targets
    end

    #
    def calculate_undefined
      covered_testunits = successes + (failures + errors + pendings).map{ |tu, e| tu }
      covered_targets = covered_testunits.map{ |tu| tu.fullname }

      targets = []
      coverage.each do |mod, meths|
        meths.each do |meth, cov|
          if /^::/ =~ meth.to_s
            targets << "#{mod}#{meth}"
          else
            targets << "#{mod}##{meth}"
          end
        end
      end

      covered_targets - targets
    end
=end

