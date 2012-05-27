## Core Extension Coverage

### Kernel Extensions

Given an example script in 'lib/extensions_example.rb' as follows:

    module Kernel
      def f1; "f1"; end
      def f2; "f2"; end
      def f3; "f3"; end
    end

And given a test case in 'test/extensions_example_case.rb' as follows:

    Covers 'extensions_example.rb'

    TestCase Kernel do
      method :f1 do
        test do
          fl.assert == "f1"
        end
      end
      method :f2 do
        test do
          f2.assert == "f2"
        end
      end
    end

And we get the coverage information via CoverageAnalyer.

    require 'lemon'

    tests = ['test/extensions_example_case.rb']

    coverage = Lemon::CoverageAnalyzer.new(tests, :loadpath=>'lib')

Then we should see that there are two covered units, #f1 and #f2.

    coverage.covered_units.size.assert == 2

    units = coverage.covered_units.map{ |u| u.to_s }

    units.assert.include?('Kernel#f1')
    units.assert.include?('Kernel#f2')

    units.refute.include?('Kernel#f3')

And we should see one unconvered unit, #f3.

    coverage.uncovered_units.size.assert == 1

    units = coverage.uncovered_units.map{ |u| u.to_s }

    units.assert.include?('Kernel#f3')

There should be zero uncovered cases.

    coverage.uncovered_cases == []

And zero undefined unit.

    coverage.undefined_units == []


