Test.covers 'example.rb'

Test.class Example do

  method :f do

    test "one and one is two"do
      Example.new.f(1,1).assert == 2
    end

    test do
      ex = Example.new
      ex.f(1,2).assert == 4
    end

  end

end

