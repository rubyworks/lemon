require 'lemon/model/test_case'
require 'lemon/model/snapshot'
#require 'lemon/model/main'

module Lemon

  # Current suite being defined. This is used
  # to define a Suite object via the toplevel DSL.
  def self.suite
    $lemon_suite #@suite ||= Lemon::TestSuite.new([])
  end

  #
  def self.suite=(suite)
    $lemon_suite = suite
  end

  # Test Suites encapsulate a set of test cases.
  #
  class TestSuite

    # Files from which the suite is loaded.
    attr :files

    # Test cases in this suite.
    attr :testcases

    # List of pre-test procedures that apply suite-wide.
    attr :before

    # List of post-test procedures that apply suite-wide.
    attr :after

    # A snapshot of the system before the suite is loaded.
    # Only set if +cover+ option is true.
    #attr :canonical

    # List of files to be covered. This primarily serves
    # as a means for allowing one test to load another
    # and ensuring converage remains accurate.
    #attr :subtest

    #attr :current_file

    #def coverage
    #  @final_coveage ||= @coverage - @canonical
    #end

    #
    #attr :options

    attr :dsl

    #
    def initialize(files, options={})
      @files   = files.flatten
      @options = options

      @testcases = []

      @before    = {}
      @after     = {}

      #load_helpers

      #if cover? or cover_all?
      #  @coverage  = Snapshot.new
      #  @canonical = Snapshot.capture
      #end

      @dsl = DSL.new(self) #, files)

      load_files
    end

    #
    #class Scope < Module
    #  def initialize
    #    extend self
    #  end
    #end

    # Iterate through this suite's test cases.
    def each(&block)
      @testcases.each(&block)
    end

    #
    def cover?
      @options[:cover]
    end

    #
    def cover_all?
      @options[:cover_all]
    end

    # TODO: automatic helper loading ?
    #def load_helpers(*files)
    #  helpers = []
    #  filelist.each do |file|
    #    dir = File.dirname(file)
    #    hlp = Dir[File.join(dir, '{test_,}helper.rb')]
    #    helpers.concat(hlp)
    #  end
    #
    #  helpers.each do |hlp|
    #    require hlp
    #  end
    #end

    #
    def load_files #(*files)
      s = Lemon.suite || self
      Lemon.suite = self

      filelist.each do |file|
        #load_file(file)
        load file #require file
      end

      Lemon.suite = s

      #if cover?
      #  $stdout << "\n"
      #  $stdout.flush
      #end

      self #return Lemon.suite
    end

    #
    #def load_file(file)
    #  #@current_file = file
    #  #if cover_all?
    #  #  Covers(file)
    #  #else
    #    file = File.expand_path(file)
    #    @dsl.module_eval(File.read(file), file)
    #    #require(file) #load(file)
    #  #end
    #end

    # Directories glob *.rb files.
    def filelist
      @filelist ||= (
        files = @files
        files = files.map{ |f| Dir[f] }.flatten
        files = files.map do |file|
          if File.directory?(file)
            Dir[File.join(file, '**', '*.rb')]
          else
            file
          end
        end.flatten
        #files = files.map{ |f| File.expand_path(f) }
        files.uniq
      )
    end

    class DSL < Module
      #
      def initialize(test_suite)
        @test_suite = test_suite
        #module_eval(&code)
      end

      # TODO: need require_find() to avoid first snapshot ?
      def covers(file)
        #if @test_suite.cover?
        #  #return if $".include?(file)
        #  s = Snapshot.capture
        #  if require(file)
        #    z = Snapshot.capture
        #    @test_suite.coverage << (z - s)
        #  end
        #else
          require file
        #end
      end
      alias_method :Covers, :covers

      # Define a test case belonging to this suite.
      def testcase(target_class, &block)
        raise "lemon: case target must be a class or module" unless Module === target_class
        @test_suite.testcases << TestCase.new(@test_suite, target_class, &block)
      end

      #
      alias_method :TestCase, :testcase
      alias_method :tests, :testcase

      # Define a pre-test procedure to apply suite-wide.
      def before(*matches, &block)
        @test_suite.before[matches] = block #<< Advice.new(match, &block)
      end
      alias_method :Before, :before

      # Define a post-test procedure to apply suite-wide.
      def after(*matches, &block)
        @test_suite.after[matches] = block #<< Advice.new(match, &block)
      end
      alias_method :After, :after

      # Includes at the suite level are routed to the toplevel.
      #def include(*mods)
      #  TOPLEVEL_BINDING.eval('self').instance_eval do
      #    include(*mods)
      #  end
      #end

    end

  end

end
