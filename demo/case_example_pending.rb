class Example
  def f(x,y)
    x + y
  end
end

TestCase Example do

  unit :f do
    raise Pending
  end

end

