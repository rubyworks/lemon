#
module M
  def m1; "m1"; end
  module N
    def self.n1; "n1"; end
  end
end

# The difference between unit test and functional testing is where the concerns fit.

# Unit Testing concerns the concerns of test units.

Case(Lemon::Test::Case) do

  include M
  #N = M::N

  Concern "Modules included in the test case are accessible",
          "by the unit tests."

  #Before /returns/ do |unit|
  #  puts "returns something"
  #end

  Unit :include => "allows access to module methods" do
    m1.assert == "m1"
  end

  Unit :include => "allows access to nested modules" do
    N::n1.assert == "n1"
  end

end

