require 'lemon/model/ae'

class Pending < Assertion
  def self.to_proc; lambda{ raise self }; end
end

class Untested < Pending
  def self.to_proc; lambda{ raise self }; end
end

