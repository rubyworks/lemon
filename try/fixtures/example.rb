class Example

  def initialize(a=1)
    @a = a
  end

  def f(x,y)
    @a * x + y
  end

  def q(x,y)
    x % y
  end

  def self.m(a,b)
    a * b
  end

end

