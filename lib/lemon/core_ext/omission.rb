# The Omission class is a subclass of NotImplementedError with 
# it's assertion flag set to true. This will be recognized by
# Ruby Test as a test omission.
#
# @example
#   test "some feature" do
#     raise Omission, "feature can't be tested"
#   end
#
class Omission < NotImplementedError
  def initialize(msg=nil, opts={})
    super(msg)
    set_backtrace(opts[:backtrace]) if opts[:backtrace]
  end
  def assertion?
    true
  end
  def to_proc
    error = self
    lambda{ raise error }
  end
end
