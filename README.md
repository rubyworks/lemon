# Lemon

[Homepage](http://rubyworks.github.com/lemon) |
[User Guide](http://wiki.github.com/rubyworks/lemon) |
[Development](http://github.com/rubyworks/lemon) |
[Issues](http://github.com/rubyworks/lemon/issues)


## DESCRIPTION

Lemon is a Unit Testing Framework that enforces a strict test structure mirroring the class/module and method structure of the target code. Arguably this promotes the proper technique for low-level unit testing and helps ensure good test coverage.

The difference between unit testing and functional testing, and all other forms of testing for that matter, is simply a matter of where the testing *concern* lies. The concerns of unit testing are the concerns of unit tests --the individual methods.

IMPORTANT! As of v0.9+ the API has changed. The `unit :name => "description"` notation is no longer supported.


## EXAMPLE

Let's say we have a script 'mylib.rb' consisting of the class X:

``` ruby
class X
  def a; "a"; end
end
```

A simplistic test case for this class would be written as follows:

``` ruby
covers 'mylib'

test_class X do

  setup "Description of setup." do
    @x = X.new
  end

  unit :a do
    test "method #a does something expected" do
      @x.a.assert.is_a? String
    end

    test "method #a does something else expected" do
      @x.a.assert == "x"
    end
  end

end
```

The `covers` method works just like `require` with the exception that it records the file for reference --under certain scenarios it can be used to improve test coverage analysis.

The setup (also called the *concern*) is run for every subsequent `test` until a new setup is defined.

In conjunction with the `#setup` method, there is a `#teardown` method which can be used "tidy-up" after each unit run if need be.

That is the bulk of the matter for writing Lemon tests. To learn about additonal features not mentioned here, check-out the [User Guide](http://wiki.github.com/rubyworks/lemon).


## USAGE

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

Lemon is distributed according to the terms of the _FreeBSD_ License.

See the COPYING.rdoc file for details.
