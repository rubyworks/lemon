module Lemon

  require 'lemon/model/test'
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

      @record  = Recorder.new #{:pass=>[], :fail=>[], :error=>[], :pending=>[], :omit=>[]}

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

    # Samples
    #
    # * .lemon/rc
    # * .lemon/rc.rb
    # * .config/lemon/rc
    # * .config/lemon/rc.rb
    #
    RC_GLOB = '{.,.config/,config/}lemon/rc{,.rb}'

    #
    def initialize_rc
      if file = Dir[RC_GLOB].first
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

=begin
    # Build test stack.
    def build
      stack = []

      stack << [:start_suite, suite]
      build_case(suite, stack) 
      stack << [:finish_suite, suite]

      return stack
    end

    #
    private
    def build_case(tcase, stack)
      tcase.each do |tc|
        if tc.respond_to?(:test)
          stack << [:start_test, tc.advice]
          stack << [:test, tc]
          stack << [:finish_test, tc.advice]
        end
        if tc.respond_to?(:each)
          stack << [:start_case, tc]
          build_case(tc, stack)
          stack << [:finish_case, tc]
        end
      end
    end

    # This will become a dedicated test harness in KO project.
    public
    def run
      report = report_find(format)

      build.each do |signal, tcase|
        report.send(signal, tcase)

        case signal
        when :test
          begin
            tcase.test

            report.pass(tcase)
            record[:pass] << tcase
          rescue Pending => exception
            report.pending(tcase, exception)
            record[:pending] << [tcase, exception]
          rescue Exception => exception
            if exception.assertion?
              report.fail(tcase, exception)
              record[:fail] << [tcase, exception]
            else
              report.error(tcase, exception)
              record[:error] << [tcase, exception]
            end
          end
        else
          tcase.send(signal)
        end
      end
    end
=end

    def record
      @record ||= Recorder.new
    end

    def observers
      @observers ||= [report, record]
    end

    #
    def run
      observers.each{ |o| o.start_suite(suite) }
      run_case(suite, report)
      observers.each{ |o| o.finish_suite(suite) }

      record.success?
    end

    #
    def run_case(cases, report)
      cases.each do |tc|
        if tc.respond_to?(:to_proc)
          run_test(tc)
        end
        if tc.respond_to?(:each)
          observers.each{ |o| o.start_case(tc) }
          run_case(tc, report)
          observers.each{ |o| o.finish_case(tc) }
        end
      end
    end

    # TODO: Add test advice as temporary observers, or 
    # keep advice internal to test.call ?
    def run_test(test)
      observers.each{ |o| o.start_test(test) }
      begin
        test.call
        observers.each{ |o| o.pass(test) }
        #report.pass(test)
        #record[:pass] << test
      rescue Pending => exception
        observers.each{ |o| o.pending(test, exception) }
        #report.pending(tc, exception)
        #record[:pending] << [test, exception]
      rescue Exception => exception
        if exception.assertion?
          observers.each{ |o| o.fail(test, exception) }
          #report.fail(test, exception)
          #record[:fail] << [test, exception]
        else
          observers.each{ |o| o.error(test, exception) }
          #report.error(test, exception)
          #record[:error] << [test, exception]
        end
      end
      observers.each{ |o| o.finish_test(test) }
    end

=begin
    # Run tests.
    #
    # @return [Boolean] 
    #   That the tests ran without error or failure.
    #
    def run_old
      #prepare
      report.start_suite(suite)
      each do |test_case|
        scope = Object.new
        scope.extend(test_case.dsl)
        report.start_case(test_case)
        if test_case.prepare #before[[]]
          scope.instance_eval(&test_case.prepare)
        end
        test_case.each do |test_unit|
          report.start_unit(test_unit)
          test_unit.each do |test|
            if test.omit?
              report.omit(test)
              record[:omit] << test
              next
            end
            report.start_test(test)
            run_pretest_procedures(test, scope) #, suite, test_case)
            begin
              run_test(test, scope)
              #test.call(scope)
              report.pass(test)
              record[:pass] << test
            rescue Pending => exception
              exception = clean_backtrace(exception)
              report.pending(test, exception)
              record[:pending] << [test, exception]
            rescue Assertion => exception
              exception = clean_backtrace(exception)
              report.fail(test, exception)
              record[:fail] << [test, exception]
            rescue Exception => exception
              exception = clean_backtrace(exception)
              report.error(test, exception)
              record[:error] << [test, exception]
            end
            report.finish_test(test)
            run_postest_procedures(test, scope) #, suite, test_case)
          end
          report.finish_unit(test_unit)
        end
        if test_case.cleanup #after[[]]
          scope.instance_eval(&test_case.cleanup)
        end
        report.finish_case(test_case)
      end
      report.finish_suite(suite) #(successes, failures, errors, pendings)
      return record[:error].size + record[:fail].size > 0 ? false : true
    end
=end

    # Iterate over suite's test cases, filtering out unselected cases
    # if any namespaces constraints are provided.
    #
    def each(&block)
      if namespaces.empty?
        suite.each do |test_case|
          block.call(test_case)
        end
      else
        suite.each do |test_case|
          next unless namespaces.any?{ |n| test_case.target.name.start_with?(n) }
          block.call(test_case)
        end
      end
    end

    # All output is handled by a reporter.
    #
    # @return [Reporter::Abstract]
    #   The particular test run reporter to use.
    #
    def report
      @report ||= report_find(format)
    end

    # Find a report type be name fragment.
    #
    # @return [Reporter::Abstract]
    #   The particular test run reporter to use.
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

    # Returns a list of available report types.
    #
    # @return [Array<String>]
    #   The names of the reporters.
    #
    def report_list
      Dir[File.dirname(__FILE__) + '/../view/test_reports/*.rb'].map do |rb|
        File.basename(rb).chomp('.rb')
      end
    end

  private

=begin
    # Run a test.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    # @param [Object] scope
    #   The scope in which to run the pre-test procedures.
    # 
    def run_test(test, scope)
      if test.function? 
        base = (class << test.test_case.target; self; end)
      else
        base = test.test_case.target
      end

      raise Pending unless test.procedure

      begin
        base.class_eval do
          alias_method "_lemon_#{test.target}", test.target
          define_method(test.target) do |*a,&b|
            test.tested = true
            __send__("_lemon_#{test.target}",*a,&b)
          end
        end
      rescue => error
        Kernel.eval <<-END, test.procedure.binding
          raise #{error.class}, "#{test.target} not tested"
        END
      end
      #Lemon.test_stack << self  # hack

      begin
        if test.context && test.procedure.arity != 0
          cntx = test.context.setup(scope)
          scope.instance_exec(cntx, &test.procedure) #procedure.call
        elsif test.context
          test.context.setup(scope)
          scope.instance_exec(&test.procedure) #procedure.call
        else
          scope.instance_exec(&test.procedure) #procedure.call
        end
        test.context.teardown(scope) if test.context
      ensure
        #Lemon.test_stack.pop
        base.class_eval %{
          alias_method "#{test.target}", "_lemon_#{test.target}"
        }
      end
      if !test.tested
        #exception = Untested.new("#{test.target} not tested")
        if RUBY_VERSION < '1.9'
          Kernel.eval %[raise Pending, "#{test.target} not tested"], test.procedure
        else
          Kernel.eval %[raise Pending, "#{test.target} not tested"], test.procedure.binding
        end
      end
    end
=end

=begin
    #
    def run_concern_procedures(concern, scope) #suite, test_case)
      tc    = concern.test_case
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
    #
    # @param [TestProc] test
    #   The test procedure instance which is to be run.
    #
    # @param [Object] scope
    #   The scope in which to run the pre-test procedures.
    # 
    def run_pretest_procedures(test, scope) #, suite, test_case)
      test.test_suite.before.each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
      test.test_case.before.each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
      test.test_unit.before.each do |matches, block|
        if matches.all?{ |match| unit.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
    end

    # Run post-test advice.
    #
    # @param [TestProc] test
    #   The test procedure instance which was run.
    #
    # @param [Object] scope
    #   The scope in which to run the post-test procedures.
    # 
    def run_postest_procedures(test, scope) #, suite, test_case)
      test.test_unit.after.each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
      test.test_case.after.each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
      test.test_suite.after.each do |matches, block|
        if matches.all?{ |match| test.match?(match) }
          scope.instance_exec(test, &block) #block.call(unit)
        end
      end
    end


  end

  #
  class Recorder

    def initialize
      @table = Hash.new{ |h,k| h[k] = [] }
    end

    def [](key)
      @table[key.to_sym]
    end

    def pass(test)
      self[:pass] << test
    end

    def fail(test, exception)
      self[:fail] << [test, exception]
    end

    def error(test, exception)
      self[:error] << [test, exception]
    end

    def pending(test, exception)
      self[:pending] << [test, exception]
    end

    def omit(test, exception)
      self[:omit] << [test, exception]
    end

    #
    def success?
      self[:error].size + self[:fail].size > 0 ? false : true
    end

    #
    def method_missing(*a)
    end
 
  end

end
