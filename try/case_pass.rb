Test.covers 'example.rb'

Test.class Example do

  method :f do

    setup "without multipler" do
      @ex = Example.new
    end

    test "1,2" do
      @ex.f(1,2).assert == 3
    end

    test "2,2" do
      @ex.f(2,2).assert == 4
    end


    setup "with multipler" do
      @ex = Example.new(2)
    end

    test "1,2" do |ex|
      @ex.f(1,2).assert == 4
    end

    test "2,2" do
      @ex.f(2,2).assert == 6
    end

    teardown do
      # ...
    end

    #class_method :m do
    #  Example.m(1,1).assert == 1
    #end

  end

end
