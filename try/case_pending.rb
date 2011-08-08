covers 'example.rb'

test_case Example do

  method :f do 

    test "one and one is two"do
      Example.new.f(1,1).assert == 2
    end

    test "pending" do
      raise NotImplementedError
    end

  end

end

