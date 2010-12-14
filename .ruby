--- 
name: lemon
title: Lemon
contact: trans <transfire@gmail.com>
requires: 
- group: []

  name: ae
  version: 0+
- group: 
  - build
  name: syckle
  version: 0+
- group: 
  - test
  name: cucumber
  version: 0+
- group: 
  - test
  name: aruba
  version: 0+
resources: 
  repository: git://github.com/proutils/lemon.git
  home: http://proutils.github.com/lemon
pom_verison: 1.0.0
manifest: 
- .ruby
- bin/lemon
- demo/case_example_fail.rb
- demo/case_example_pass.rb
- demo/case_example_pending.rb
- demo/case_example_untested.rb
- demo/fixture/example-use.rb
- demo/fixture/example.rb
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
- lib/lemon/view/test_reports/verbose.rb
- lib/lemon.rb
- lib/lemon.yml
- test/api/applique/fs.rb
- test/api/coverage/complete.rdoc
- test/api/coverage/extensions.rdoc
- test/api/coverage/incomplete.rdoc
- test/cli/coverage.feature
- test/cli/generate.feature
- test/cli/step_definitions/coverage_steps.rb
- test/cli/support/ae.rb
- test/cli/support/aruba.rb
- test/cli/test.feature
- test/fixtures/case_complete.rb
- test/fixtures/case_inclusion.rb
- test/fixtures/case_incomplete.rb
- test/fixtures/example.rb
- test/fixtures/helper.rb
- test/runner
- test/unit/case_coverage_analyzer.rb
- test/unit/case_test_case_dsl.rb
- HISTORY.rdoc
- LICENSE
- README.rdoc
- Version
version: 0.8.2
suite: proutils
copyright: Copyright 2009 Thomas Sawyer
licenses: 
- Apache 2.0
description: Lemon is a unit testing framework that tightly correlates class to test case and method to test unit.
summary: Pucker-tight Unit Testing
authors: 
- Thomas Sawyer
