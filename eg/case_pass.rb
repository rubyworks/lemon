covers File.dirname(__FILE__) + '/fixture/example.rb'

testcase Example do

  setup "without multipler" do
    Example.new
  end

  unit :f do |ex|
    ex.f(1,2).assert == 3
    ex.f(2,2).assert == 4
  end

  setup "with multipler" do
    Example.new(2)
  end

  unit :f => "incorporate the multiplier" do |ex|
    ex.f(1,2).assert == 4
    ex.f(2,2).assert == 6
  end

  teardown do
    # ...
  end

  meta :m do
    Example.m(1,1).assert == 1
  end

end

