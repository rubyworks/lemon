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
  def assertion?
    true
  end
  def to_proc
    error = self
    lambda{ raise error }
  end
end
