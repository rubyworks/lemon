#!/usr/bin/env ruby

require 'test/rake'

Test::Rake::TestTask.new do |t|
  t.tests    << 'test/*.rb'
  t.loadpath << 'test/fixtures'
end

namespace :test do

  desc 'run lemon unit tests (via shell command)'
  task :unit do
    sh 'lemonade test -Itest/fixtures test/*.rb'
  end

  desc 'run qed demonstration tests'
  task :qed do
    sh 'qed -Ilib qed/'
  end

end

