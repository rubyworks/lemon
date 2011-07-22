Test.covers 'example.rb'

Test.class Example do

  method :f do
 
    test "nothing doing" do
      # notice Example#f has not been called
    end

  end

end

