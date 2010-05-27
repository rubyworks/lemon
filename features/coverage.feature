Feature: Coverage
  As a developer
  In order to improve test coverge
  I want to able to write tests with coverage in mind
  And receive effective coverage reports

  Scenario: Complete Example Case
    Given a directory named "example"
    Given a file named "example/lib/example.rb" with:
      """
      class X
        def a; "a"; end
        def b; "b"; end
        def c; "c"; end
      end
      class Y
        def q; "q"; end
      end
      """
    Given a file named "example/test/case_complete.rb" with:
      """
      Covers 'example'
      TestCase X do
        Unit :a => "Returns a String" do ; end
        Unit :b => "Returns a String" do ; end
        Unit :c => "Returns a String" do ; end
      end
      TestCase Y do
        Unit :q => "Returns a String" do ; end
      end
      """
    When I cd to "example"
    And I run "lemon -c -Ilib test/case_complete.rb"
    Then the stdout should contain "0 uncovered cases"
    And the stdout should contain "0 uncovered units"
    And the stdout should contain "0 undefined units"

  Scenario: Incomplete Example Case
    Given a directory named "example"
    Given a file named "example/lib/example.rb" with:
      """
      class X
        def a; "a"; end
        def b; "b"; end
        def c; "c"; end
      end
      class Y
        def q; "q"; end
      end
      """
    Given a file named "example/test/case_complete.rb" with:
      """
      Covers 'example'
      TestCase X do
        Unit :a => "Returns a String" do ; end
        Unit :b => "Returns a String" do ; end
        Unit :d => "Returns a String" do ; end
      end
      """
    When I cd to "example"
    And I run "lemon -c -Ilib test/case_complete.rb"
    Then the stdout should contain "1 uncovered cases"
    And the stdout should contain "1 uncovered units"
    And the stdout should contain "1 undefined units"

