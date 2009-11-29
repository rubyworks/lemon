module Lemon

  module Test

    #
    class Unit

      #
      attr :test_case

      #
      attr :test_method

      #
      attr :test_concern

      #
      def initialize(test_case, target_method, target_concern, &test_procedure)
        @test_case      = test_case
        @test_method    = target_method
        @test_concern   = target_concern
        @test_procedure = test_procedure
      end

      #
      def call
        @test_procedure.call
      end

      #
      def to_proc
        @test_procedure
      end

      #
      def to_s
        "#{test_case}##{test_method} #{test_concern}"
      end

      #def concern(description, &block)
      #  @concerns << Concern.new(description, &block)
      #end

      #def each(&block)
      #  @concerns.each(&block)
      #end
    end

  end

end


  #
  #class Concern
  #  attr :description
  #
  #  def initialize(description, &block)
  #    @description = description
  #    @testblock   = block
  #  end
  #
  #  def call
  #    @testblock.call
  #  end
  #end

