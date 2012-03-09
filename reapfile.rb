#!/usr/bin/env ruby

desc "run all tests"
task :test => [:unit, :qed]

desc 'run lemon unit tests (via shell command)'
task :unit do
  system 'lemons test -Ilib -Itest/fixtures test/*.rb'
end

desc 'run qed demonstrations'
task :qed do
  system 'qed -Ilib spec/'
end

