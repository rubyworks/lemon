module Lemon
module Test

  require 'lemon/test/case'
  require 'lemon/dsl'

  # Test Suites encapsulate a set of test cases.
  #
  class Suite

    # Files from which the suite is loaded.
    attr :files

    # Script the suite covers. There files are
    # required just before running the suite.
    attr :covers

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

    #
    def initialize(*files)
      @files          = files.flatten
      @covers         = []
      @testcases      = []
      @before_clauses = {}
      @after_clauses  = {}
      @when_clauses   = {}

      load_helpers

      #@canonical = system_snapshot

      load_files(*files)
    end

    #
    def take_snapshot
      @canonical = system_snapshot
    end

    # Produces a list of all existent Modules and Classes.
    def system_snapshot
      sys = []
      ObjectSpace.each_object(Module) do |m|
        sys << m
      end
      sys
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
    def load_files(*files)
      Lemon.suite = self
      filelist.each do |file|
        #file = File.expand_path(file)
        #instance_eval(File.read(file), file)
        load(file)
      end
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

    #
    def load_covered_files
      covers.each do |file|
        require file
      end
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
    def Covers(file)
      @covers << file
    end

    # Iterate through this suite's test cases.
    def each(&block)
      @testcases.each(&block)
    end

  end

end
end
