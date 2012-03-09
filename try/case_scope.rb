covers 'example.rb'

test_case Example do

  method :f do

    test "foo is available" do
      foo.assert == "foo"
      Example.new.f(1,2)
    end

  end

  # Helper method.
  def foo
    "foo"
  end

end
