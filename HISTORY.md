# RELEASE HISTORY

## 0.9.1 / 2012-03-09

Thie release fixes some evaluation scope issues, improves how omit and skip
methods work, makes test generation usable and general cleans-up internals.
All in all this release should be a fair bit more robust that previous releases
and ready for the big One-Oh after one more good golf session.

Changes:

* Fix test scope so it's properly isolated.
* Improve skip and omit methods w/ non-block forms.
* Use Ripper instead of RubyParse for scaffolding.
* Greatly improve usability of code generation tool.


## 0.9.0 / 2011-08-11

Version 0.9 is a huge release for Lemon. This release finally makes the transition
to the new unit subcase syntax --a bit more verbose than the old style but a more
flexible means of notating unit tests allowing each unit to group together mutiple
tests. For previous users you will need to change old style tests, e.g.

  Unit :to_s => "that string" do
    ...
  end

To the new style:

  Unit :to_s do
    Test "that string" do
      ...
    end
  end

This release also moves Lemon over to the new Ruby Test library for test runs.
The `lemon` command line interface has changed and now uses subcommands rather than command
opitions. So use `lemon coverage` instead of the old `lemon -c`. Since Lemon now uses Ruby
Test to run tests, `lemon test` is equivalent to `ruby-test`, and the Ruby Test config file
should be used to configure test runs instead of `.lemonrc` which is no longer supported.

Changes:

* Utilize Ruby Test for test execution.
* Implemented new unit block syntax.


## 0.8.5 / 2011-07-15

This release fixes exit code status, which should be -1 if there
are errors or failures.

Changes:

* Fix exit code status.


## 0.8.4 / 2011-07-11

Fix reported issue #6 to get lemon passing it own tests. (Note: the
tests need to be run with `test/fixtures` in the loadpath). There was 
also a typo in the Outline reporter which was fixed. And better support
of the newest ANSI gem now lets color be deactivated with the --no-ansi
command line option.

Changes:

* Fix typo in outline reporter.
* Add --no-ansi command line option.
* Load ansi/core per the latest ANSI gem.
* Lemon can test itself (albeit test are not complete).


## 0.8.3 / 2011-05-19

Looks like Lemon is pretty damn near 1.0 status. She probably won't get
any major changes for a good while. This release simply adds TAP-Y/J reporters.
Just use `-f tapy` or `-f tapj` on the command line.

Changes:

* Add TAP-Y/J reporters.
* Configuration directory can be `.lemon/`.


## 0.8.2 / 2010-09-05

This release overhauls how coverage is performed so it does not need to
take a system snapshot after requiring each covered file. This greatly
improves Lemon's speed. In addition #setup and #teardown have been introduced
for performing procedures before and after each unit test.

Changes:

* Overhaul coverage analysis.
* Add TestCase#setup and #teardown methods.
* TestCase#concern and #context are just aliases of #setup.
* Improved output formats.


## 0.8.1 / 2010-07-11

This release adds a timer to the verbose output, which help isolate unit tests
that are slow. It also fixed bug in Before and After advice that prevented them
from triggering correctly.

Changes:

* Add times to verbose reporter.


## 0.8.0 / 2010-06-21

This release removes coverage information from testing. Coverage can be time
consuming, but running test should be as fast as possbile. For this reason 
coverage and testing are kept two independent activities. This release also
adds some test coverage for Lemon itself via Cucumber.

Changes:

* Separated coverage from testing completely.
* Test generator defaults to public methods only.


## 0.7.0 / 2010-05-04

This release fixes issue with coverage reports. To do this we have interoduced
the +Covers+ method. This allows Lemon to distingush between code that is
inteded to be covered by the tests and mere support code.

Keep in mind that there is no perfect way to handle coverage. Even with the
distiction the +Covers+ method provides, coverage might not be reported exactly
as desired. Other techinques can be used to refine coverage however, such
a preloading embedded support libraries.

Changes:

* Add +Covers+ method to solidify coverage reporting.
* New Snapshot class improves encapsulation to coverage state.


## 0.6.0 / 2010-03-06

This release adds coverage reporting to testing and improves the generator.

Changes:

* Runner can provide uncovered and undefined testunit list.
* Generator can exclude already covered testunits with -u option.
* Suite class has Coverage instance.


## 0.5.0 / 2009-12-31

This is the initial public release of Lemon. Lemon is still under development
and should be considered betaware, but it's API is stable and the system usable
enough to warrant a release.

Changes:

* Happy First Release Day!

