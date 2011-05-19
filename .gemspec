--- !ruby/object:Gem::Specification 
name: lemon
version: !ruby/object:Gem::Version 
  prerelease: 
  version: 0.8.2
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-05-19 00:00:00 Z
dependencies: 
- !ruby/object:Gem::Dependency 
  name: ae
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :runtime
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: syckle
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id002
- !ruby/object:Gem::Dependency 
  name: cucumber
  prerelease: false
  requirement: &id003 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id003
- !ruby/object:Gem::Dependency 
  name: aruba
  prerelease: false
  requirement: &id004 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id004
description: Lemon is a unit testing framework that tightly correlates class to test case and method to test unit.
email: transfire@gmail.com
executables: 
- lemon
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- .ruby
- bin/lemon
- demo/case_example_error.rb
- demo/case_example_fail.rb
- demo/case_example_pass.rb
- demo/case_example_pending.rb
- demo/case_example_untested.rb
- demo/fixture/example-use.rb
- demo/fixture/example.rb
- features/coverage.feature
- features/generate.feature
- features/step_definitions/coverage_steps.rb
- features/support/ae.rb
- features/support/aruba.rb
- features/test.feature
- lib/lemon/cli.rb
- lib/lemon/controller/coverage_analyzer.rb
- lib/lemon/controller/scaffold_generator.rb
- lib/lemon/controller/test_runner.rb
- lib/lemon/model/ae.rb
- lib/lemon/model/cover_unit.rb
- lib/lemon/model/main.rb
- lib/lemon/model/pending.rb
- lib/lemon/model/snapshot.rb
- lib/lemon/model/source_parser.rb
- lib/lemon/model/test_case.rb
- lib/lemon/model/test_context.rb
- lib/lemon/model/test_suite.rb
- lib/lemon/model/test_unit.rb
- lib/lemon/view/cover_reports/abstract.rb
- lib/lemon/view/cover_reports/compact.rb
- lib/lemon/view/cover_reports/outline.rb
- lib/lemon/view/cover_reports/verbose.rb
- lib/lemon/view/cover_reports/yaml.rb
- lib/lemon/view/test_reports/abstract.rb
- lib/lemon/view/test_reports/dotprogress.rb
- lib/lemon/view/test_reports/html.rb
- lib/lemon/view/test_reports/outline.rb
- lib/lemon/view/test_reports/summary.rb
- lib/lemon/view/test_reports/tap.rb
- lib/lemon/view/test_reports/tapj.rb
- lib/lemon/view/test_reports/tapy.rb
- lib/lemon/view/test_reports/verbose.rb
- lib/lemon.rb
- lib/lemon.yml
- qed/applique/fs.rb
- qed/coverage/01_complete.rdoc
- qed/coverage/02_incomplete.rdoc
- qed/coverage/03_extensions.rdoc
- test/case_coverage_analyzer.rb
- test/case_test_case_dsl.rb
- test/fixtures/case_complete.rb
- test/fixtures/case_inclusion.rb
- test/fixtures/case_incomplete.rb
- test/fixtures/example.rb
- test/fixtures/helper.rb
- test/runner
- HISTORY.rdoc
- APACHE2.txt
- README.rdoc
- NOTICE.rdoc
homepage: http://proutils.github.com/lemon
licenses: 
- Apache 2.0
post_install_message: 
rdoc_options: 
- --title
- Lemon API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
requirements: []

rubyforge_project: lemon
rubygems_version: 1.8.2
signing_key: 
specification_version: 3
summary: Pucker-tight Unit Testing
test_files: []

