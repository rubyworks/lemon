if RUBY_VERSION < '1.9'
  require 'lemon/ignore_callers'
else
  require_relative 'ignore_callers'
end

module Lemon

  # The World module is the base class for all Lemon test scopes.
  # To add test specific helper methods for your tests, place them here.
  #
  class World < Module
  end

end

