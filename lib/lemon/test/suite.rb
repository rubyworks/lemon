module Lemon
module Test

  require 'lemon/test/case'
  require 'lemon/dsl'

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

    #
    def initialize(*files)
      @testcases      = []
      @before_clauses = {}
      @after_clauses  = {}
      @when_clauses   = {}

      loadfiles(*files)
    end

    #
    def loadfiles(*files)
      Lemon.suite = self

      # directories glob *.rb files
      files = files.flatten.map do |file|
        if File.directory?(file)
          Dir[File.join(file, '**', '*.rb')]
        else
          file
        end
      end.flatten.uniq

      files.each do |file|
        #file = File.expand_path(file)
        #instance_eval(File.read(file), file)
        load(file)
      end

      return Lemon.suite
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

    # Iterate through this suite's test cases.
    def each(&block)
      @testcases.each(&block)
    end

  end

end
end

