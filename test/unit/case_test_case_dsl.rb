TestCase Lemon::TestCase::DSL do

  Prepare do
    @files = ['test/fixtures/case_inclusion.rb']
  end

  Instance "Modules included in a test case are accessible by the unit tests." do
    ts = Lemon::TestSuite.new(@files)
    tc = ts.testcases.first  # the only one
    tc.dsl
  end

  Unit :include, "allows access to module methods" do |dsl|
    mod = Module.new{ def x; "x"; end }
    dsl.include(mod)
    # how to test?
  end

  # I do not think it is possible to make this work using dyanmic module
  # construction. Please correct me if you know otherwise. To fix
  # would mean turning test cases into classes instead of objects. Maybe
  # we will do this in the future.
  Omit :include, "allows access to nested modules" do |dsl|
    mod = Module.new{ N = 1 }
    dsl.include(mod)
    dsl::N == 1
  end

  Instance "Test cases are augmented by prepare and cleanup procedures." do
    ts = Lemon::TestSuite.new(@files)
    tc = ts.testcases.first  # the only one
    tc.dsl
  end

  Unit :Prepare => "setup a pre-testcase procedure" do |dsl|
    dsl.Prepare{ }
    # how to test?
  end

  Unit :Cleanup => "setup a post-testcase procedure" do |dsl|
    dsl.Cleanup{ }
    # how to test?
  end

end

