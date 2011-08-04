require 'lemon/model/test_case'
require 'lemon/model/test_method'
require 'lemon/model/test_module'
require 'lemon/model/test_feature'
require 'lemon/model/snapshot'
#require 'lemon/model/main'
require 'lemon/core_ext/kernel'

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
    attr :cases

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
    attr :options

    attr :stack

    attr :dsl

    #
    def initialize(files, options={})
      @files   = files.flatten
      @options = options

      @cases   = []
      @helpers = []

      @before  = {}
      @after   = {}

      load_helpers

      #if cover? or cover_all?
      #  @coverage  = Snapshot.new
      #  @canonical = Snapshot.capture
      #end

      @dsl = DSL.new(self) #, files)

      load_files
    end

    #
    def cover?
      @options[:cover]
    end

    #
    def cover_all?
      @options[:cover_all]
    end

    #
    #class Scope < Module
    #  def initialize
    #    extend self
    #  end
    #end

    def to_a
      @cases
    end

    # Iterate through this suite's test cases.
    def each(&block)
      @cases.each(&block)
    end

    #
    def advice
      @advice ||= TestAdvice.new
    end

    #
    def subject
      @subject
    end

=begin
    #
    def start_suite
    end

    #
    def finish_suite
    end
=end

    #
    def scope
      s = Object.new
      s.extend(dsl)
      s
    end

    # Automatically load helpers. Helpers are any *.rb script in
    # a `helpers` directory, relative to a test script.
    #
    # TODO: You can change the file pattern used to automatically
    # load helper scripts in `.lemon`.
    #
    def load_helpers
      helpers = []
      filelist.each do |file|
        dir = File.dirname(file)
        hlp = Dir[File.join(dir, 'helper{s,}/*.rb')]
        helpers.concat(hlp)
      end
      helpers.uniq!
      helpers.each do |hlp|
        require File.expand_path(hlp)
      end
      @helpers = helpers
    end

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
        files.reject{ |f| /fixture(|s)\/(.*?)\.rb$/ =~ f }
        files.reject{ |f| /helper(|s)\/(.*?)\.rb$/ =~ f }
      )
    end

    # TODO: Note sure about scope creation here
    def scope
      @scope ||= (
        scope = Object.new
        scope.extend(dsl)
      )
    end

    class DSL < Module
      #
      def initialize(suite)
        @suite = suite
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
      def test_case(description, &block)
        options = {
         :description => description
        }
        @suite.cases << TestCase.new(@suite, options, &block)
      end

      #
      alias_method :TestCase, :test_case

      # Define a module test case belonging to this suite.
      def test_module(target_module, &block)
        raise "lemon: target must be a module" unless Module === target_module
        options = {
          :target => target_module
        }
        @suite.cases << TestModule.new(@suite, optios, &block)
      end

      # Define a class test case belonging to this suite.
      def test_class(target_class, &block)
        raise "lemon: case target must be a class" unless Class === target_class
        options = {
          :target => target_class
        }
        @suite.cases << TestModule.new(@suite, options, &block)
      end

      # Define a test feature.
      def test_feature(target, &block)
        options = {
          :target => target
        }
        @suite.cases << TestFeature.new(@suite, options, &block)
      end

      # Define a pre-test procedure to apply suite-wide.
      def before(*matches, &block)
        @suite.before[matches] = block #<< Advice.new(match, &block)
      end
      alias_method :Before, :before

      # Define a post-test procedure to apply suite-wide.
      def after(*matches, &block)
        @suite.after[matches] = block #<< Advice.new(match, &block)
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
