--- 
name: lemon
version: 0.8.4
title: Lemon
summary: Pucker-tight Unit Testing
description: Lemon is a unit testing framework that tightly correlates class to test case and method to test unit.
loadpath: 
- lib
manifest: MANIFEST
requires: 
- name: ae
  version: 0+
  group: []

- name: ansi
  version: 1.3+
  group: []

- name: detroit
  version: 0+
  group: 
  - build
- name: reap
  version: 0+
  group: 
  - build
- name: qed
  version: 0+
  group: 
  - test
- name: cucumber
  version: 0+
  group: 
  - test
- name: aruba
  version: 0+
  group: 
  - test
conflicts: []

replaces: []

engine_check: []

suite: proutils
contact: trans <transfire@gmail.com>
copyright: Copyright 2009 Thomas Sawyer
licenses: 
- Apache 2.0
authors: 
- Thomas Sawyer
maintainers: []

resources: 
  home: http://proutils.github.com/lemon
  repository: git://github.com/proutils/lemon.git
repositories: {}

spec_version: 1.0.0
