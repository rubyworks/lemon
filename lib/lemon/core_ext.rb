if RUBY_VERSION > '1.9'
  require_relative 'core_ext/kernel'
  require_relative 'core_ext/module'
  require_relative 'core_ext/omission'
else
  require 'lemon/core_ext/kernel'
  require 'lemon/core_ext/module'
  require 'lemon/core_ext/omission'
end
