module Lemon

  class World < Module

    #def omit(message)
    #  err = NotImplementedError.new(message)
    #  err.set_assertion(true)
    #  raise err
    #end

  end

end

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
