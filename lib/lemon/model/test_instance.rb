module Lemon

  # Test Instances are used to organize unit tests into groups, so as to address
  # specific scenarios for a given class.
  class TestInstance

    # The test case to which this concern belongs.
    attr :testcase

    # The description of this concern. Make this
    # as detailed as you wish.
    attr :description

    # New case instance.
    def initialize(testcase, description, options={}, &block)
      @testcase    = testcase
      @description = description.to_s
      @singleton   = options[:singleton]
      @block       = block
    end

    # Returns the description with newlines removed.
    def to_s
      description.gsub(/\n/, ' ')
    end

    # Create instance.
    def setup
      if @singleton
        @testcase.target
      else
        @block.call if @block
      end
    end

    def meta?
      @singleton
    end
  end

 #class TestSingleton < Instance
 #   def initialize(testcase, *description)
 #     @testcase    = testcase
 #     @description = description.join("\n")
 #   end
 #
 #   def setup
 #     testcase.target
 #   end
 #
 #    def meta?
 #     true 
 #   end
 #end

end

