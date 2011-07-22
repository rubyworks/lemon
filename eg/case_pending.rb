Test.covers 'example.rb'

Test.class Example do

  method :f do 

    test "one and one is two"do
      Example.new.f(1,1).assert == 2
    end

    test "pending" do
      raise Pending
    end

  end

end

