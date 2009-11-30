module Lemon

  module Test

    #
    class Case

      #
      attr :test_suite

      #
      attr :test_class

      #
      attr :test_units

      #
      attr :before_clauses

      #
      attr :after_clauses

      #
      def initialize(test_suite, test_class, &block)
        @test_suite = test_suite
        @test_class = test_class
        @test_units = []
        @before_clauses = {}
        @after_clauses  = {}
        instance_eval(&block)
      end

      #
      def Unit(targets, &block)
        targets.each do |target_method, target_concern|
          @test_units << Unit.new(self, target_method, target_concern, &block)
        end
      end

      #
      alias_method :unit, :Unit

      #
      def Before(match=nil, &block)
        @before_clauses[match] = block #<< Advice.new(match, &block)
      end

      alias_method :before, :Before

      #
      def After(match=nil, &block)
        @after_clauses[match] = block #<< Advice.new(match, &block)
      end

      alias_method :after, :After

      #
      def each(&block)
        @test_units.each(&block)
      end

      #
      def to_s
        test_class.to_s.sub(/^\#\<.*?\>::/, '')
      end
    end

  end

end

