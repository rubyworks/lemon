require 'lemon/model/test_clause'

module Lemon

  #
  class TestScenario < TestCase

    #
    def initialize(feature, summary, options={}, &block)
      @feature = feature
      @summary = summary

      @tests   = []

      evaluate(&block)
    end
  
    #
    def evaluate(&procedure)
      @dsl = DSL.new(self, &procedure)
    end

    #
    attr :feature

    #
    attr :dsl

    attr_accessor :omit

    #
    def omit?
      @omit
    end

    #
    def to_s
      "Scenario: #{@summary}"
    end

    def subject

    end

    #
    def run(clause)
      type = clause.type
      desc = clause.description
      feature.advice[type].each do |mask, proc|
        if md = match_regexp(mask).match(desc)
          scope.instance_exec(*md[1..-1], &proc)
        end
      end
    end

    #
    #--
    # TODO: Change so that the scope is the DSL
    #       and includes the DSL of the context?
    #++
    def scope
      @scope ||= (
        #if feature
        #  scope = feature.scope || Object.new
        #  scope.extend(dsl)
        #else
          scope = Object.new
          scope.extend(dsl)
        #end
      )
    end

    #
    #def find
    #  features.clauses[@type].find{ |c| c =~ @description }
    #end

    # Convert matching string into a regular expression. If the string
    # contains double parenthesis, such as ((.*?)), then the text within
    # them is treated as in regular expression and kept verbatium.
    #
    # TODO: Better way to isolate regexp. Maybe ?:(.*?) or /(.*?)/.
    #
    def match_regexp(str)
      str = str.split(/(\(\(.*?\)\))(?!\))/).map{ |x|
        x =~ /\A\(\((.*)\)\)\Z/ ? $1 : Regexp.escape(x)
      }.join
      str = str.gsub(/\\\s+/, '\s+')
      Regexp.new(str, Regexp::IGNORECASE)
    end


    # TODO: Need to ensure the correct order of Given, When, Then.
    class DSL < Module

      #
      def initialize(scenario, &code)
        @scenario = scenario

        module_eval(&code)
      end

      # Given ...
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def Given(description)
        @scenario.tests << TestClause.new(@scenario, description, :type=>:given)
      end
      alias_method :given, :Given

      # When ...
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def When(description)
        @scenario.tests << TestClause.new(@scenario, description, :type=>:when)
      end
      alias_method :wence, :When

      # Then ...
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def Then(description)
        @scenario.tests << TestClause.new(@scenario, description, :type=>:then)
      end
      alias_method :hence, :Then

    end

  end

end
