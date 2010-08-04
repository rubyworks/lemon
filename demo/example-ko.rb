require 'lemon/aid/example'

feature "Example" do

  scenario "#f" do
    ex = Example.new
    ex.f(1,2).assert == 3
  end

end

