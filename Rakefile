require 'rubygems/package_task'

gemspec = Gem::Specification.load('lemon.gemspec')

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc "Run QED demos"
task :test do
  sh 'bundle exec qed'
end

task :default => :test
