## Incomplete Coverage

### Incomplete Coverage of Public Interface

Given an example script in 'lib/incomplete_example.rb' as follows:

    class I1
      def f1; "f1"; end
      def f2; "f2"; end
      def f3; "f3"; end
    end

    class I2
      def g1; "g1"; end
      protected
      def g2; "g2"; end
      private
      def g3; "g3"; end
    end

    class I3
      def h1; "h1"; end
    end

And given a test case in 'test/incomplete_example_case.rb' as follows:

    Covers 'incomplete_example.rb'

    TestCase I1 do
      method :f1 do
        test "Returns a String"
      end
      method :f2 do
        test "Returns a String"
      end
    end

    TestCase I2 do
      method :x1 do
        test "Does not exist"
      end
    end

And we get the coverage information via CoverageAnalyer.

    require 'lemon'

    tests = ['test/incomplete_example_case.rb']

    coverage = Lemon::CoverageAnalyzer.new(tests, :loadpath=>'lib')

Then we should see that there are 2 unconvered units, I1#f3 and I2#g1
because no testcase unit was defined for them and they are both public methods.

    units = coverage.uncovered_units.map{ |u| u.to_s }

    units.assert.include?('I1#f3')
    units.assert.include?('I2#g1')

    units.size.assert == 2

You might expect that 'I3#h1' would be in the uncovered units list as well,
since it is a public method and no test unit covers it. However, there is
no test case for I3 at all, so Lemon takes that to mean that I3 is of
no interest.

    units.refute.include?('I3#h1')

But I3 will be listed in the uncovered cases list.

    coverage.uncovered_cases == [I3]

Note that uncovered case methods can be included in the uncovered units list
by setting the +zealous+ option, which we will demonstrated later.

There should still be 3 covered units, I1#f1, I1#f2 and I2#x1.

    coverage.covered_units.size.assert == 3

    units = coverage.covered_units.map{ |u| u.to_s }

    units.assert.include?('I1#f1')
    units.assert.include?('I1#f2')
    units.assert.include?('I2#x1')

But we will not find any covered units for class I2.

    units.refute.include?('I2#g1')
    units.refute.include?('I2#g2')
    units.refute.include?('I2#g3')

Notice also that we defined a unit for I2#x1, a method that does not exist.
So it should be listed in the undefined units list.

    coverage.undefined_units.size.assert == 1

    units = coverage.undefined_units.map{ |u| u.to_s }

    units.assert.include?('I2#x1')

