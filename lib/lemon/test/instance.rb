module Lemon::Test

  # Test Instances are used to organize unit tests into groups, so as to address
  # specific scenarios for a given class.
  class Instance

    # The test case to which this concern belongs.
    attr :testcase

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # New case instance.
    def initialize(testcase, *description, &block)
      @testcase    = testcase
      @description = description.join("\n")
      @block       = block
    end

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end

    # Create instance.
    def setup
      @block.call
    end

    def meta?
      false
    end
  end

  class Singleton < Instance
    def initialize(testcase, *description)
      @testcase    = testcase
      @description = description.join("\n")
    end

    def setup
      testcase.target
    end

    def meta?
      true 
    end
  end

end

