module Lemon::Test

  require 'lemon/test/concern'
  require 'lemon/test/unit'

  # Test Case encapsulates a collection of 
  # unit tests organized into groups of concern.
  class Case

    # The test suite to which this testcase belongs.
    attr :suite

    # A testcase +target+ is a class or module.
    attr :target

    #
    attr :testunits

    # List of before procedures that apply case-wide.
    attr :before_clauses

    # List of after procedures that apply case-wide.
    attr :after_clauses

    # List of concern procedures that apply case-wide.
    attr :when_clauses

    # A test case +target+ is a class or module.
    def initialize(suite, target, &block)
      @suite          = suite
      @target         = target
      @testunits      = []
      @concerns       = []
      @before_clauses = {}
      @after_clauses  = {}
      @when_clauses   = {}
      instance_eval(&block)
    end

    # Load a helper script applicable to this test case.
    def helper(file)
      instance_eval(File.read(file), file)
    end

    # NOTE: Due to a limitation in Ruby this does not
    # provived access to submodules. A hack has been used
    # to circumvent. See Suite.const_missing.
    def include(*mods)
      extend *mods
    end

    # Define a new test concern for this case.
    # TODO: Probably will deprecate the &setup procedure (YAGNI).
    def Concern(*description, &setup)
      concern = Concern.new(self, description, &setup)
      @concerns << concern
    end

    alias_method :concern, :Concern

    # The last defined concern. Used to assign new unit tests.
    def current_concern
      if @concerns.empty?
        @concerns << Concern.new(self)
      end
      @concerns.last
    end

    # Iterate over each test concern.
    def each(&block)
      @concerns.each(&block)
    end

    # Define a unit test for this case.
    def Unit(*targets, &block)
      targets_hash = Hash===targets.last ? targets.pop : {}
      targets_hash.each do |target_method, target_concern|
        @testunits << Unit.new(current_concern, target_method, target_concern, &block)
      end
      targets.each do |target_method|
        @testunits << Unit.new(current_concern, target_method, &block)
      end
    end
    alias_method :unit, :Unit

    # Define a before procedure for this case.
    def Before(match=nil, &block)
      @before_clauses[match] = block #<< Advice.new(match, &block)
    end
    alias_method :before, :Before

    # Define an after procedure for this case.
    def After(match=nil, &block)
      @after_clauses[match] = block #<< Advice.new(match, &block)
    end
    alias_method :after, :After

    # Define a concern procedure to apply case-wide.
    def When(match=nil, &block)
      @when_clauses[match] = block #<< Advice.new(match, &block)
    end

    #
    #def pending
    #  raise Pending
    #end

    #
    def to_s
      target.to_s.sub(/^\#\<.*?\>::/, '')
    end
  end

end

class Pending < Assertion
  def self.to_proc; lambda{ raise self }; end
end

