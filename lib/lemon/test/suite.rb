module Lemon
module Test

  require 'lemon/test/case'

  # Test Suites encapsulate a set of test cases.
  #
  class Suite

    # Test cases in this suite.
    attr :testcases

    # List of concern procedures that apply suite-wide.
    attr :when_clauses

    # List of pre-test procedures that apply suite-wide.
    attr :before_clauses

    # List of post-test procedures that apply suite-wide.
    attr :after_clauses

    # List of concern procedures that apply suite-wide.
    attr :when_clauses

    #
    def initialize(*tests)
      @testcases      = []
      @before_clauses = {}
      @after_clauses  = {}
      @when_clauses   = {}

      # directories glob *.rb files
      tests = tests.flatten.map do |file|
        if File.directory?(file)
          Dir[File.join(file, '**', '*.rb')]
        else
          file
        end
      end.flatten.uniq

      @test_files = tests

      tests.each do |file|
        #file = File.expand_path(file)
        instance_eval(File.read(file), file)
      end
    end

    # Load a helper. This method must be used when loading local
    # suite support. The usual #require or #load can only be used
    # for extenal support libraries (such as a test mock framework).
    # This is so because suite code is not evaluated at the toplevel.
    def helper(file)
      instance_eval(File.read(file), file)
    end

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
      testcases << Case.new(self, target_class, &block)
    end

    #
    alias_method :TestCase, :Case

    #
    alias_method :testcase, :Case

    # Define a pre-test procedure to apply suite-wide.
    def Before(match=nil, &block)
      @before_clauses[match] = block #<< Advice.new(match, &block)
    end

    alias_method :before, :Before

    # Define a post-test procedure to apply suite-wide.
    def After(match=nil, &block)
      @after_clauses[match] = block #<< Advice.new(match, &block)
    end

    alias_method :after, :After

    # Define a concern procedure to apply suite-wide.
    def When(match=nil, &block)
      @when_clauses[match] = block #<< Advice.new(match, &block)
    end

    # Iterate through this suite's test cases.
    def each(&block)
      @testcases.each(&block)
    end

    # FIXME: This is a BIG FAT HACK! For the life of me I cannot find
    # a way to resolve module constants included in the test cases.
    # Becuase of closure, the constant lookup goes through here, and not
    # the Case singleton class. So to work around wemust note each test
    # before it is run, and reroute the missing constants.
    #
    # This sucks and it is not thread safe. If anyone know how to fix,
    # please let me know. See Unit#call for the other end of this hack.

    def self.const_missing(name)
      (class << @@test_stack.last.testcase; self; end).const_get(name)
    end

    # Get current running test. Used for the BIG FAT HACK.
    def test_stack
      @@test_stack ||= []
    end

  end

end
end

