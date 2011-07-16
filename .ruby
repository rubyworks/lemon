---
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: Thomas Sawyer
  year: '2009'
  license: BSD-2-Clause
replacements: []
conflicts: []
requirements:
- name: ae
- name: ansi
  version: 1.3+
- name: detroit
  groups:
  - build
  development: true
- name: reap
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
- name: cucumber
  groups:
  - test
  development: true
- name: aruba
  groups:
  - test
  development: true
dependencies: []
repositories:
- uri: git://github.com/proutils/lemon.git
  scm: git
  name: origin
resources:
  home: http://rubyworks.github.com/lemon
  code: http://github.com/rubyworks/lemon
load_path:
- lib
extra:
  manifest: MANIFEST
alternatives: []
revision: 0
title: Lemon
suite: proutils
summary: Pucker-tight Unit Testing
description: Lemon is a unit testing framework that tightly correlates class to test
  case and method to test unit.
version: 0.8.5
name: lemon
date: '2011-07-16'
