module Lemon::Test

  # Test Concerns are used to organize unit tests
  # in groups, so as to address specific quality
  # assurance objectives.
  class Concern

    # The test case to which this concern belongs.
    attr :testcase

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # Unit tests that belong to this concern.
    attr :testunits

    # New concern.
    def initialize(testcase, *description)
      @testcase    = testcase
      @description = description.join("\n")
      @testunits   = []
    end

    # Assign a unit test to this concern.
    def assign(testunit)
      raise ArgumentError unless Unit === testunit
      @testunits << testunit
    end

    # Iterate through each test unit.
    def each(&block)
      @testunits.each(&block)
    end

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end

  end

end
