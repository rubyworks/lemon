class Example
  def f(x,y)
    x + y
  end
end

TestCase Example do

  unit :f do
    # notice Example#f has not been called
  end

end

