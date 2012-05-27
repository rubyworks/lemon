## Complete Coverage

### Complete Coverage of Public Interface

Given an example script in 'lib/complete_example.rb' as follows:

    class C1
      def f1; "f1"; end
      def f2; "f2"; end
      def f3; "f3"; end
    end

    class C2
      def g1; "g1"; end
      protected
      def g2; "g2"; end
      private
      def g3; "g3"; end
    end

And given a test case in 'test/complete_example_case.rb' as follows:

    Covers 'complete_example.rb'

    TestCase C1 do
      method :f1 do 
        test "Returns a String"
      end
      method :f2 do
        test "Returns a String"
      end
      method :f3 do
        test "Returns a String"
      end
    end

    TestCase C2 do
      method :g1 do
        test "Returns a String"
      end
    end

And we get the coverage information via CoverageAnalyer.

    require 'lemon'

    tests = ['test/complete_example_case.rb']

    coverage = Lemon::CoverageAnalyzer.new(tests, :loadpath=>'lib')

Then we should see that there are no uncovered units.

    coverage.uncovered_units.assert == []

And there should be 4 covered units,

    coverage.covered_units.size.assert == 4

one for each public class and method.

    units = coverage.covered_units.map{ |u| u.to_s }

    units.assert.include?('C1#f1')
    units.assert.include?('C1#f2')
    units.assert.include?('C1#f3')

    units.assert.include?('C2#g1')

There should not be any coverage for private and protected methods.

    units.refute.include?('C2#g2')
    units.refute.include?('C2#g3')

In addition there should be no uncovered_cases or undefined_units.

    coverage.undefined_units.assert = []
    coverage.uncovered_cases.assert = []

### Including Private and Protected Methods

We will use the same example classes as above, but in this case we will
add coverage for private and protected methods as well, given a test case
in 'test/complete_example_case.rb' as follows:

    Covers 'complete_example.rb'

    TestCase C1 do
      method :f1 do
        test "Returns a String"
      end
      method :f2 do
        test "Returns a String"
      end
      method :f3 do
        test "Returns a String"
      end
    end

    TestCase C2 do
      method :g1 do
        test "Returns a String"
      end
      method :g2 do
        test "Returns a String"
      end
      method :g3 do
        test "Returns a String"
      end
    end

And we get the coverage information via CoverageAnalyer.

    require 'lemon'

    tests = ['test/complete_example_case.rb']

    coverage = Lemon::CoverageAnalyzer.new(tests, :loadpath=>'lib', :private=>true)

Notice the use of the +private+ option. This will add private and protected
methods to the coverage analysis.

Then we should see that there are no uncovered units.

    coverage.uncovered_units.assert == []

And there should be 6 covered units,

    coverage.covered_units.size.assert == 6

one for each class and method.

    units = coverage.covered_units.map{ |u| u.to_s }

    units.assert.include?('C1#f1')
    units.assert.include?('C1#f2')
    units.assert.include?('C1#f3')

    units.assert.include?('C2#g1')
    units.assert.include?('C2#g2')
    units.assert.include?('C2#g3')

In addition there should be no uncovered cases or undefined units.

    coverage.undefined_units.assert = []
    coverage.uncovered_cases.assert = []

