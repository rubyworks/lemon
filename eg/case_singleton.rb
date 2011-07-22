Test.covers 'example.rb'

Test.class Example.singleton_class do

  method :m do

    setup "Example class" do
      Example
    end

    test "using singleton_class" do
      Example.m(1,1).assert == 1
    end

  end

end

# Same thing but using sexy Latin name.
Test.class Example.qua_class do

  method :m do

    test "using qua_class" do
      Example.m(1,1).assert == 1
    end

  end

end

