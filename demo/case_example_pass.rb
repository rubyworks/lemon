Covers File.dirname(__FILE__) + '/example.rb'

TestCase Example do

  instance "without multipler" do
    Example.new
  end

  Unit :f do |ex|
    ex.f(1,2).assert == 3
    ex.f(2,2).assert == 4
  end

  instance "with multipler" do
    Example.new(2)
  end

  Unit :f => "incorporate the multiplier" do |ex|
    ex.f(1,2).assert == 4
    ex.f(2,2).assert == 6
  end

  teardown do
    # ...
  end

  singleton

  Unit :m do |ex|
    ex.assert == Example
    ex.m(1,1).assert == 1
  end

end

