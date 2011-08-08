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
