module Lemon

  module Test

    #
    class Suite < Module

      #
      attr :test_cases

      #
      def initialize(*tests)
        @test_cases = []

        # directories glob *.rb files
        tests = tests.flatten.map do |file|
          if File.directory?(file)
            Dir[File.join(file, '**', '*.rb')]
          else
            file
          end
        end.flatten.uniq

        tests.each do |file|
          #file = File.expand_path(file)
          instance_eval(File.read(file))
        end
      end

      #
      #def load(file)
      #  instance_eval(File.read(file))
      #end

      #
      def TestCase(target_class, &block)
        test_cases << Case.new(self, target_class, &block)
      end

      #
      alias_method :testcase, :TestCase

      #
      def each(&block)
        @test_cases.each(&block)
      end
    end

  end

end

