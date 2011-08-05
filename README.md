# Lemon

[Homepage](http://rubyworks.github.com/lemon) |
[Development](http://github.com/rubyworks/lemon) |
[Issues](http://github.com/rubyworks/lemon/issues)


## DESCRIPTION

Lemon is a Unit Testing Framework that enforces a test case construction mirroring the class/module and method design of the target system. Arguably this promotes the proper technique for unit testing and helps ensure good test coverage.

The difference between unit testing and functional testing, and all other forms of testing for that matter, is simply a matter of where the *concern* lies. The concerns of unit testing are the concerns of unit tests -- the individual methods.

IMPORTANT! As of v0.9+ the API has changed. The `unit :name => "description"`
notation is no longer supported. Use `unit :name do test "description"` instead.


## HOW TO USE

### Writing Tests

Say our library 'mylib.rb' consists of the class X:

    class X
      def a; "a"; end
    end

The simplest test case would be written as follows:

    Test.covers 'mylib'

    Test.class X do
      method :a do
        test "method #a does something expected" do
          x = X.new
          x.a.assert.is_a? String
        end
      end
    end

The `Covers` method works just like `require` with the exception that Lemon records the file for reference --under certain scenarios it can be used to improve overall test covered.

As tests grow, we might need to organize them into special concerns. For this Lemon provides a #concern method and a #setup method. Technically the two methods are the same, but #concern is used more for descriptive purposes whereas #setup is used to create an instance of the test case's target class.

    Test.covers 'mylib'

    Test.class X do
      method :a do
        setup "Description of concern that the following unit tests address." do
          X.new
        end

        test "method #a does something expected" do |x|
          x.a.assert.is_a? String
        end
      end
    end

Notice that the parameter passed to the block of `unit` method is the instance of `X` created in the `setup` block. This block is run for every subsequent `Unit` until a new concern is defined.

In conjunction with the #setup methods, there is a #teardown method which can be used "tidy-up" after each unit run if need be.

Lastly, there are the `before` and `after` methods which can be used only once for each test case. The `before` method defines a procedure to run before any of the test case's units are run, and the `after` method defines a procedure to run after that are all finished.

That is the bulk of the matter for writing Lemon tests. There are few other features not mentioned here. You can learn more about those by reading the [Lemon Wiki](http://wiki.github.com/rubyworks/lemon).


### Running Tests

Tests can be run using the `lemonade` command line tool.

    $ lemonade test test/cases/name_case.rb

Lemon utilizes the Ruby Test system to run tests, the `lemonade test` command simply passes off the running of tests to `ruby-test`. So the `ruby-test` command-line utility can also be used directly:

    $ ruby-test -r lemon test/cases/name_case.rb

Normal output is typical _dot-progress_. Other output types can be specified by the `--format` or `-f` option.

    $ ruby-test -r lemon -f tap test/cases/name_case.rb

See [Ruby Test](http://rubyworks.github.com/test) for more information.

### Checking Test Coverage

Lemon can check test coverage by loading your target system and comparing it to your tests. To do this use the <code>lemonade coverage</code> command the utility.

    $ lemonade coverage -Ilib test/cases/*.rb

The coverage tool provides class/module and method coverage and is meant to as a "guidance system" for developers working toward complete test coverage. It is not an lines-of-code coverage tool and should not be considered a substitute for one.

### Generating Test Skeletons

Because of the one to one correspondence of test case and unit test to class/module and method, Lemon can also generate test scaffolding for previously written code. To do this, use the <code>lemonade generate</code> command line utility and provide the lib location or files of the scripts for which to generate test scaffolding, and the output location for the test scripts.

    $ lemonade generate -Ilib test/cases/*.rb

Generating test case scaffolding from code will undoubtedly strike test-driven developers as a case of putting the cart before the horse. However, it is not unreasonable to argue that high-level, behavior-driven, functional testing frameworks, such as Q.E.D. and Cucumber are better suited to test-first methodologies. While test-driven development can obviously be done with Lemon, unit-testing is more appropriate for testing specific, critical portions of code, or for achieving full test coverage for mission critical applications.

### Test Directory

There is no special directory for Lemon tests. Since they are unit tests, `test/` or `test/unit/` are good choices. Other options are `cases/` and `test/cases` since each file generally defines a single test case.


## COPYRIGHTS

Lemon Unit Testing Framework

Copyright (c) 2009 Thomas Sawyer 

Lemon is distributed according to the terms of the *FreeBSD* License.

See the COPYING.rdoc file for details.
