# Some fixture code for testing #include.
module M
  def m1; "m1"; end
  module N
    def self.n1; "n1"; end
  end
end

TestCase Lemon::Test::Case do

  Concern "Modules included in a test case are accessible by the unit tests."

  include M
  #N = M::N

  Unit :include => "allows access to module methods" do
    m1.assert == "m1"
  end

  Unit :include => "allows access to nested modules" do
    N::n1.assert == "n1"
  end


  Concern "Unit tests are augmented by before and after procedures."

  Before /pre-test/ do |unit|
    @check_before = :before
  end

  After /pre-test/ do |unit|
    @check_after = :after
  end

  Unit :Before => "sets up a pre-test procedure" do
    @check_before.assert == :before
  end

  Unit :After => "sets up a post-test procedure" do
    @check_after.assert == :after
  end


  #Concern "Unit tests are augmented by when procedures.",
  #        "(NOTE: we have to repeat this concern in order to test it.)"

  When /augmented\ by\ when\ procedures/ do
    @check_concern = :concern
  end

  Concern "Unit tests are augmented by when procedures."

  Unit :Concern => "sets up a concern procedure" do
    @check_concern.assert == :concern
  end

end

