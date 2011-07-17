covers File.dirname(__FILE__) + '/fixture/example.rb'

testcase Example.singleton_class do

  unit :m do
    Example.m(1,1).assert == 1
  end

end

# Same thing but using sexy Latin name.
testcase Example.quaclass do

  unit :m do
    Example.m(1,1).assert == 1
  end

end

