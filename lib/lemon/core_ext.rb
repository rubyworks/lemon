if RUBY_VERSION > '1.9'
  require_relative 'core_ext/kernel'
  require_relative 'core_ext/module'
else
  require 'lemon/core_ext/kernel'
  require 'lemon/core_ext/module'
end
