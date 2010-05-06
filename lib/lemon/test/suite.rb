module Lemon
module Test

  require 'lemon/test/case'
  require 'lemon/dsl'

  # Test Suites encapsulate a set of test cases.
  #
  class Suite

    # Files from which the suite is loaded.
    attr :files

    # Test cases in this suite.
    attr :testcases

    # List of concern procedures that apply suite-wide.
    attr :when_clauses

    # List of pre-test procedures that apply suite-wide.
    attr :before_clauses

    # List of post-test procedures that apply suite-wide.
    attr :after_clauses

    # A snapshot of the system before the suite is loaded.
    attr :canonical

    # Instance of snapshot recording coverage information.
    #attr :coverage

    #
    attr :options

    #
    def initialize(files, options={})
      @files          = files.flatten
      @options        = options

      #@coverage       = Snapshot.new
      @testcases      = []
      @before_clauses = {}
      @after_clauses  = {}
      @when_clauses   = {}

      load_helpers
      take_snapshot
      load_files
    end

    #
    def cover?
      options[:cover]
    end

    #
    def take_snapshot
      @canonical = Snapshot.capture
    end

    #
    def load_helpers(*files)
      helpers = []
      filelist.each do |file|
        dir = File.dirname(file)
        hlp = Dir[File.join(dir, '{test_,}helper.rb')]
        helpers.concat(hlp)
      end

      helpers.each do |hlp|
        require hlp
      end
    end

    #
    def load_files #(*files)
      #if cover?
      #  $stdout << "Load: "
      #end

      Lemon.suite = self
      filelist.each do |file|
        #file = File.expand_path(file)
        #instance_eval(File.read(file), file)
        require(file) #load(file)
      end

      #if cover?
      #  $stdout << "\n"
      #  $stdout.flush
      #end

      return Lemon.suite
    end

    # Directories glob *.rb files.
    def filelist
      @filelist ||= (
        @files.flatten.map do |file|
          if File.directory?(file)
            Dir[File.join(file, '**', '*.rb')]
          else
            file
          end
        end.flatten.uniq
      )
    end

    ## Load a helper. This method must be used when loading local
    ## suite support. The usual #require or #load can only be used
    ## for extenal support libraries (such as a test mock framework).
    ## This is so because suite code is not evaluated at the toplevel.
    #def helper(file)
    #  instance_eval(File.read(file), file)
    #end

    #
    #def load(file)
    #  instance_eval(File.read(file), file)
    #end

    # Includes at the suite level are routed to the toplevel.
    def include(*mods)
      TOPLEVEL_BINDING.eval('self').instance_eval do
        include(*mods)
      end
    end

    # Define a test case belonging to this suite.
    def Case(target_class, &block)
      raise "lemon: case target must be a class or module" unless Module === target_class
      testcases << Case.new(self, target_class, &block)
    end

    #
    alias_method :TestCase, :Case

    #
    #alias_method :testcase, :Case

    # Define a pre-test procedure to apply suite-wide.
    def Before(match=nil, &block)
      @before_clauses[match] = block #<< Advice.new(match, &block)
    end

    #alias_method :before, :Before

    # Define a post-test procedure to apply suite-wide.
    def After(match=nil, &block)
      @after_clauses[match] = block #<< Advice.new(match, &block)
    end

    #alias_method :after, :After

    # Define a concern procedure to apply suite-wide.
    def When(match=nil, &block)
      @when_clauses[match] = block #<< Advice.new(match, &block)
    end

    #
    def coverage
      Snapshot.capture - canonical
    end

    #
    def Covers(file)
      #if cover?
      #  $stdout.print '.'; $stdout.flush
      #  s1 = Snapshot.capture
      #  require file
      #  s2 = Snapshot.capture
      #  dx = (s2 - s1)
      #  @covers << dx
      #else
        require file
      #end
    end

    # Iterate through this suite's test cases.
    def each(&block)
      @testcases.each(&block)
    end

  end

end
end

