#!/usr/bin/env ruby

require './lib/lemon/rake'

Lemon::Rake::TestTask.new do |t|
  t.format = 'verbose'
end

namespace :test do

  desc 'run lemon unit tests (via shell command)'
  task :unit do
    sh 'lemon -Itest/fixtures test/*.rb'
  end

  desc 'run qed demonstration tests'
  task :qed do
    sh 'qed'
  end

end

