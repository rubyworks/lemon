require 'lemon/model/pending'
require 'lemon/model/test_context'
require 'lemon/model/test_advice'
require 'lemon/model/test_scenario'

module Lemon

  # The TestFeature ...
  #
  # * `tests` are _scenarios_,
  # * `advice` are _given_, _when_ and _then_ rules.
  #
  class TestFeature < TestCase

    #
    def initialize(context, settings={}, &block)
      @story = []
      super(context, settings, &block)
    end

    ## This has to be redefined in each subclass to pick
    ## up there respective DSL classes.
    #def evaluate(&block)
    #  @dsl = DSL.new(self, &block)
    #end
  
    attr :story

    # Feature scenarios are tests.
    alias_method :scenarios, :tests

    #
    def to_s
      "Feature #{target}"
    end

    #
    def to_s #description
      (["Feature: #{target}"] + story).join("\n  ")
    end

    # Run test in the context of this case.
    #
    # @param [TestProc] test
    #   The test procedure instance to run.
    #
    def run(&block)
    end

    #
    class DSL < Module

      #
      def initialize(feature, &code)
        @feature = feature

        module_eval(&code)
      end

      #
      def To(description)
        @feature.story << "To " + description
      end

      #
      def As(description)
        @feature.story << "As " + description
      end

      #
      def We(description)
        @feature.story << "We " + description
      end

      #
      def Scenario(description, &procedure)
        scenario = TestScenario.new(@feature, description, &procedure)
        @feature.scenarios << scenario
        scenario
      end
      alias_method :scenario, :Scenario

      # Omit a scenario from test runs.
      #
      #  omit unit :foo do
      #    # ...
      #  end
      #
      def Omit(scenario)
        scenario.omit = true
      end
      alias_method :omit, :Omit

      # Given ...
      #
      # @param [String] description
      #   A brief description of the _given_ criteria.
      #
      def Given(description, &procedure)
        @feature.advice[:given][description] = procedure
      end
      alias_method :given, :Given

      # When ...
      #
      # @param [String] description
      #   A brief description of the _when_ criteria.
      #
      def When(description, &procedure)
        @feature.advice[:when][description] = procedure
      end
      alias_method :wence, :When

      # Then ...
      #
      # @param [String] description
      #   A brief description of the _then_ criteria.
      #
      def Then(description, &procedure)
        @feature.advice[:then][description] = procedure
      end
      alias_method :hence, :Then

    end

  end

end
