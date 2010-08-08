Covers File.dirname(__FILE__) + '/example.rb'

require File.dirname(__FILE__) + '/helper.rb'

TestCase X do

  include HelperMixin

  Unit :a => "Returns a String" do
    X.new.a
  end

  Unit :b => "Returns a String" do
    X.new.b
  end

end

