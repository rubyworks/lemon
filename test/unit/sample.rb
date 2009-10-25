# fixture

class X
  def a; "a"; end
end

# test

testcase X do

  unit :a do

    should 'returns a string' do
      X.new.a.assert.is_a?(String)
    end

    should 'returns lowercase' do
      X.new.a.assert =~ /^[a-z]*$/
    end

    should 'can be broken' do
      1.assert == 4
    end

  end

end


testcase X do

  unit :a, 'returns a string' do
    X.new.a.assert.is_a?(String)
  end

  unit :a, 'returns lowercase' do
    X.new.a.assert =~ /^[a-z]*$/
  end

  unit :a, 'can be broken' do
    1.assert == 4
  end

end
