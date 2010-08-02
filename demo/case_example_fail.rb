
class Example

  def f(x,y)
    x + y
  end
  
end

TestCase Example do

  unit :f do
    ex = Example.new
    ex.f(1,2).assert == 4
  end

end

