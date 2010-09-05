covers File.dirname(__FILE__) + '/example.rb'

require File.dirname(__FILE__) + '/helper.rb'

testcase X do

  include HelperMixin

  unit :a => "Returns a String" do
    X.new.a
  end

  unit :b => "Returns a String" do
    X.new.b
  end

end

