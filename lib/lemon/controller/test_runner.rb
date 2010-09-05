module Lemon

  require 'lemon/model/main'
  require 'lemon/model/test_suite'

  # The TestRunner class handles the execution of Lemon tests.
  class TestRunner

    # Test suite to run.
    attr :suite

    #
    attr :files

    # Report format.
    attr :format

    # Record pass, fail, error, pending and omitted units.
    attr :record

    # New Runner.
    def initialize(files, options={})
      @files = files
      @options = options

      @record  = {:pass=>[], :fail=>[], :error=>[], :pending=>[], :omit=>[]}

      ## TODO: can we create and assign the suite here?
      @suite  = Lemon::TestSuite.new(files)  #([])
      #@suite = Lemon.suite

      initialize_rc  # TODO: before or after @suite = 

      #files = files.map{ |f| Dir[f] }.flatten
      #files = files.map{ |f| 
      # if File.directory?(f)
      #    Dir[File.join(f, '**/*.rb')]
      #  else
      #   f 
      #  end
      #}.flatten.uniq
      #files = files.map{ |f| File.expand_path(f) }
      #files.each{ |s| require s }
    end

    #
    def initialize_rc
      if file = Dir['./{.,}config/lemon/rc.rb'].first
        require file
      end
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
        if testcase.prepare #before[[]]
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
            run_pretest_procedures(unit, scope) #, suite, testcase)
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
            run_postest_procedures(unit, scope) #, suite, testcase)
          #end
        end
        if testcase.cleanup #after[[]]
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

    # Find a report type be name fragment.
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

    # Returns a list of report types.
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

      begin
        base.class_eval do
          alias_method "_lemon_#{unit.target}", unit.target
          define_method(unit.target) do |*a,&b|
            unit.tested = true
            __send__("_lemon_#{unit.target}",*a,&b)
          end
        end
      rescue => error
        Kernel.eval %[raise #{error.class}, "#{unit.target} not tested"], unit.procedure
      end
      #Lemon.test_stack << self  # hack

      begin
        if unit.context && unit.procedure.arity != 0
          cntx = unit.context.setup(scope)
          scope.instance_exec(cntx, &unit.procedure) #procedure.call
        else
          scope.instance_exec(&unit.procedure) #procedure.call
        end
        unit.context.teardown(scope) if unit.context
      ensure
        #Lemon.test_stack.pop
        base.class_eval %{
          alias_method "#{unit.target}", "_lemon_#{unit.target}"
        }
      end
      if !unit.tested
        #exception = Untested.new("#{unit.target} not tested")
        if RUBY_VERSION < '1.9'
          Kernel.eval %[raise Pending, "#{unit.target} not tested"], unit.procedure
        else
          Kernel.eval %[raise Pending, "#{unit.target} not tested"], unit.procedure.binding
        end
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

    EXCLUDE = Regexp.new(Regexp.escape(File.dirname(File.dirname(__FILE__))))

    # Remove reference to lemon library from backtrace.
    # TODO: Matching `bin/lemon` is not robust.
    def clean_backtrace(exception)
      trace = exception.backtrace
      trace = trace.reject{ |t| t =~ /bin\/lemon/ }
      trace = trace.reject{ |t| t =~ EXCLUDE }
      if trace.empty?
        exception
      else
        exception.set_backtrace(trace)
        exception
      end
    end

  end

end

