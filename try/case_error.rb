covers 'example.rb'

test_class Example do

  method :f do

    test "one and one is two" do
      ExampleUnknown.new.f(1,1).assert == 2
    end

    test "two and two is four" do
      ExampleUnknown.new.f(2,2).assert == 4
    end

  end

end

