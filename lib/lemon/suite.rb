module Lemon

  module Test

    #
    class Suite < Module

      #
      attr :test_cases

      #
      def initialize(*test_files)
        @test_files = test_files
        @test_cases = []
        test_files.each do |file|
          load(File.expand_path(file))
        end
      end

      def load(file)
        instance_eval(File.read(file))
      end

      #
      def Test(target_class, &block)
        test_cases << Case.new(self, target_class, &block)
      end

      #
      alias_method :testcase, :Test

      #
      def each(&block)
        @test_cases.each(&block)
      end
    end

  end

end

