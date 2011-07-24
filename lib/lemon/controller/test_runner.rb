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

    #
    def record
      @record ||= Recorder.new
    end

    #
    def observers
      @observers ||= [report, record]
    end

    # Ruby test suite.
    #
    # @return [Boolean] 
    #   That the tests ran without error or failure.
    #
    def run
      observers.each{ |o| o.start_suite(suite) }
      run_case(suite, report)
      observers.each{ |o| o.finish_suite(suite) }

      record.success?
    end

    # Run a test case.
    #
    # TODO: Filter out exclude namespaces.
    def run_case(cases, report)
      cases.each do |tc|
        if tc.respond_to?(:call)
          run_test(tc)
        end
        if tc.respond_to?(:each)
          observers.each{ |o| o.start_case(tc) }
          run_case(tc, report)
          observers.each{ |o| o.finish_case(tc) }
        end
      end
    end

    # Run a test.
    #
    # @param [TestProc] test
    #   The test to run.
    #
    #--
    # TODO: Techincally test advice could be handled as temporary observers.
    # Would this be better design?
    #++
    def run_test(test)
      if test.omit?
        observers.each{ |o| o.omit(test) }
        return
      end

      observers.each{ |o| o.start_test(test) }
      begin
        test.call
        observers.each{ |o| o.pass(test) }
      rescue Pending => exception
        observers.each{ |o| o.pending(test, exception) }
      rescue Exception => exception
        if exception.assertion?
          observers.each{ |o| o.fail(test, exception) }
        else
          observers.each{ |o| o.error(test, exception) }
        end
      end
      observers.each{ |o| o.finish_test(test) }
    end

=begin
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
=end

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

=begin
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
=end

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
