module Lemon

  #require 'lemon/model/main'
  require 'lemon/model/test_suite'

  #
  class TestRunner

    # Test suite to run.
    attr :suite

    # Report format.
    attr :format

    # Record pass, fail, error, pending and omitted units.
    attr :record

    # Record of successful tests.
    #attr :successes

    # Record of failed tests.
    #attr :failures

    # Record of errors.
    #attr :errors

    # Record of pending tests.
    #attr :pendings

    # Record of pending tests.
    #attr :omits

    # New Runner.
    def initialize(suite, options={})
      @suite   = suite
      @options = options

      @record  = {:pass=>[], :fail=>[], :error=>[], :pending=>[], :omit=>[]}
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
      report.start_suite(suite)
      each do |testcase|
        scope = Object.new
        scope.extend(testcase.dsl)
        report.start_case(testcase)
        if testcase.prepare
          scope.instance_eval(&testcase.prepare)
        end
        testcase.each do |unit|
          #case step
          #when TestInstance
          #  reporter.report_instance(step)
          #when TestUnit
          #  unit = step
            if unit.omit?
              report.omit(unit)
              record[:omit] << unit
              next
            end
            report.start_unit(unit)
            #run_pretest_procedures(unit, scope) #, suite, testcase)
            begin
              run_unit(unit, scope)
              #unit.call(scope)
              report.pass(unit)
              record[:pass] << unit
            rescue Pending => exception
              exception = clean_backtrace(exception)
              report.pending(unit, exception)
              record[:pending] << [unit, exception]
            rescue Assertion => exception
              exception = clean_backtrace(exception)
              report.fail(unit, exception)
              record[:fail] << [unit, exception]
            rescue Exception => exception
              exception = clean_backtrace(exception)
              report.error(unit, exception)
              record[:error] << [unit, exception]
            end
            report.finish_unit(unit)
            #run_postest_procedures(unit, scope) #, suite, testcase)
          #end
        end
        if testcase.cleanup
          scope.instance_eval(&testcase.cleanup)
        end
        report.finish_case(testcase)
      end
      report.finish_suite(suite) #(successes, failures, errors, pendings)
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
    def report
      @report ||= report_find(format)
    end

    #
    def report_find(format)
      format = format ? format.to_s.downcase : 'dotprogress'
      format = report_list.find do |r|
        /^#{format}/ =~ r
      end
      raise "unsupported format" unless format
      require "lemon/view/test_reports/#{format}"
      reporter = Lemon::TestReports.const_get(format.capitalize)
      reporter.new(self)
    end

    #
    def report_list
      Dir[File.dirname(__FILE__) + '/../view/test_reports/*.rb'].map do |rb|
        File.basename(rb).chomp('.rb')
      end
    end

  private

    #
    def run_unit(unit, scope)
      if unit.function? 
        base = (class << unit.testcase.target; self; end)
      else
        base = unit.testcase.target
      end
      raise Pending unless unit.procedure
      base.class_eval do
        alias_method :__lemon__, unit.target
        define_method(unit.target) do |*a,&b|
          unit.tested = true
          __lemon__(*a,&b)
        end
      end
      #Lemon.test_stack << self  # hack
      begin
        if unit.instance && unit.procedure.arity != 0
          inst = unit.instance.setup(scope)
          scope.instance_exec(inst, &unit.procedure) #procedure.call
        else
          scope.instance_exec(&unit.procedure) #procedure.call
        end
        unit.instance.teardown(scope) if unit.instance
      ensure
        #Lemon.test_stack.pop
        base.class_eval %{
          alias_method :#{unit.target}, :__lemon__
        }
      end
      if !unit.tested
        #exception = Untested.new("#{unit.target} not tested")
        Kernel.eval %[raise Pending, "#{unit.target} not tested"], procedure
      end
    end

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

=begin
    # Run pre-test advice.
    def run_pretest_procedures(unit, scope) #, suite, testcase)
      suite = unit.testcase.suite
      suite.before.each do |matches, block|
        if matches.all?{ |match| unit.match?(match) }
          scope.instance_exec(unit, &block) #block.call(unit)
        end
      end
      unit.testcase.before.each do |matches, block|
        if matches.all?{ |match| unit.match?(match) }
          scope.instance_exec(unit, &block) #block.call(unit)
        end
      end
    end

    # Run post-test advice.
    def run_postest_procedures(unit, scope) #, suite, testcase)
      suite = unit.testcase.suite
      unit.testcase.after.each do |matches, block|
        if matches.all?{ |match| unit.match?(match) }
          scope.instance_exec(unit, &block) #block.call(unit)
        end
      end
      suite.after.each do |matches, block|
        if matches.all?{ |match| unit.match?(match) }
          scope.instance_exec(unit, &block) #block.call(unit)
        end
      end
    end
=end

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

