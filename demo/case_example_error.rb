covers File.dirname(__FILE__) + '/fixture/example.rb'

testcase Example do

  unit :f => "one and one is two"do
    ExampleUnknown.new.f(1,1).assert == 2
  end

end

