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

Lemon tests are broken down into target class or module and target methods.
Withn these lie the acutal tests.

Let's say we have a script 'mylib.rb' consisting of the class X:

``` ruby
class X
  def a; "a"; end
end
```

An test case for the class would be written:

``` ruby
Covers 'mylib'

TestCase X do

  Setup "Description of setup." do
    @x = X.new
  end

  Unit :a do
    Test "method #a does something expected" do
      @x.a.assert.is_a? String
    end

    Test "method #a does something else expected" do
      @x.a.assert == "x"
    end
  end

end
```

The `covers` method works just like `require` with the exception that it records the file for reference --under certain scenarios it can be used to improve test coverage analysis.

The setup (also called the *concern*) is run for every subsequent test until a new setup is defined.

In conjunction with the `#setup` method, there is a `#teardown` method which can be used "tidy-up" after each test if need be.

You might have also notice by the documentation that the test methods do not have to be capitalized.

That is the bulk of the matter for writing Lemon tests. To learn about additonal features not mentioned here, check-out the [User Guide](http://wiki.github.com/rubyworks/lemon).


## USAGE

### Running Tests

Tests can be run using the `lemons` command line tool.

    $ lemons test test/cases/name_case.rb

Lemon utilizes the RubyTest universal test harness to run tests, the `lemons test` command simply passes off control to `rubytest` command. So the `rubytest` command-line utility can also be used directly:

    $ rubytest -r lemon test/cases/name_case.rb

Normal output is typically a _dot progression_. Other output types can be specified by the `--format` or `-f` option.

    $ rubytest -r lemon -f tapy test/cases/name_case.rb

See [RubyTest](http://rubyworks.github.com/rubytest) for more information.

### Checking Test Coverage

Lemon can check per-unit test coverage by loading your target system and comparing it to your tests. To do this use the `lemons coverage` command.

    $ lemons coverage -Ilib test/cases/*.rb

The coverage tool provides class/module and method coverage and is meant to as a "guidance system" for developers working toward complete test coverage. It is not a LOC (lines of code) coverage tool and should not be considered a substitute for one.

### Generating Test Skeletons

Because of the one to one correspondence of test case and unit test to class/module and method, Lemon can also generate test scaffolding for previously written code. To do this, use the `lemons generate` or `lemons scaffold` command line utilities. 

The `generate` command outputs test skeletons to the console. You can use this output as a simple reference or redirect the output to a file and then copy and paste portions into separate files as desired. The `scaffold` command will create actual files in your test directory. Other than that, and the options that go with it (e.g. `--output`) the two commands are the same.

To get a set of test skeletons simply provide the files to be covered.

    $ lemons generate lib/**/*.rb

The generator can take into account tests already written, so as not to include units that already have test. To do this provide a list of teest files after a dash (`-`).

    $ lemons generate -Ilib lib/**/*.rb - test/**/*.rb

Test skeletons can be generated on a per-file or per-case bases. By case is the default. Use the `-f`/`--file` option to do otherwise.

    $ lemon scaffold -f lib/foo.rb

The default output location is `test/`. You can change this with the `-o/--output` option.

Generating test case scaffolding from code will undoubtedly strike test-driven developers (TDD) as a case of putting the cart before the horse. However, it is not unreasonable to argue that high-level, behavior-driven, functional testing frameworks, such as Q.E.D. and Cucumber are better suited to test-first methodologies. While test-driven development can obviously be done with Lemon, unit-testing is more appropriate for testing specific, critical portions of code, or for achieving full test coverage for mission critical applications.

### Test Directory

There is no special directory for Lemon tests. Since they are unit tests, `test/` or `test/unit/` are good choices. Other options are `cases/` and `test/cases` since each file generally defines a single test case.


## COPYRIGHTS

Lemon Unit Testing Framework

Copyright (c) 2009 Thomas Sawyer, Rubyworks

Lemon is distributable in accordance with the **FreeBSD** license.

See the LICENSE.txt for details.
