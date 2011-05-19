--- 
spec_version: 1.0.0
replaces: []

loadpath: 
- lib
name: lemon
repositories: {}

conflicts: []

engine_check: []

title: Lemon
contact: trans <transfire@gmail.com>
resources: 
  repository: git://github.com/proutils/lemon.git
  home: http://proutils.github.com/lemon
maintainers: []

requires: 
- group: []

  name: ae
  version: 0+
- group: 
  - build
  name: redline
  version: 0+
- group: 
  - build
  name: reap
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
- group: 
  - test
  name: cucumber
  version: 0+
- group: 
  - test
  name: aruba
  version: 0+
suite: proutils
manifest: MANIFEST
version: 0.8.3
licenses: 
- Apache 2.0
copyright: Copyright 2009 Thomas Sawyer
authors: 
- Thomas Sawyer
description: Lemon is a unit testing framework that tightly correlates class to test case and method to test unit.
summary: Pucker-tight Unit Testing
