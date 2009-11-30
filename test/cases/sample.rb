# fixture

class X
  def a; "a"; end
end

# Example of a Lemon Test Case

TestCase X do

  Before /returns/ do |unit|
    puts "returns something"
  end

  Unit :a => 'returns a string' do
    X.new.a.assert.is_a?(String)
  end

  Unit :a => 'returns lowercase' do
    X.new.a.assert =~ /^[a-z]*$/
  end

  Unit :a => 'can be broken' do
    1.assert == 4
  end

end

