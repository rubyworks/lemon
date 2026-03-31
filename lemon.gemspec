Gem::Specification.new do |s|
  s.name        = 'lemon'
  s.version     = '0.9.2'
  s.summary     = 'Pucker-strength Unit Testing'
  s.description = 'Lemon is a unit testing framework that tightly correlates ' \
                  'class to test case and method to test unit.'

  s.authors     = ['Thomas Sawyer']
  s.email       = ['transfire@gmail.com']

  s.homepage    = 'https://github.com/rubyworks/lemon'
  s.license     = 'BSD-2-Clause'

  s.required_ruby_version = '>= 3.1'

  s.files       = Dir['lib/**/*', 'bin/*', 'LICENSE.txt', 'README.md', 'HISTORY.md', 'demo/**/*']
  s.bindir      = 'bin'
  s.executables = ['lemons']
  s.require_paths = ['lib']

  s.add_dependency 'rubytest', '>= 0.8'
  s.add_dependency 'ae', '>= 1.8'
  s.add_dependency 'ansi', '>= 1.5'

  s.add_development_dependency 'rake', '>= 13'
  s.add_development_dependency 'qed', '>= 2.9'
end
