Feature: Coverage
  As a developer
  In order to improve test coverge
  I want to able to write unit tests that target methods
  And run those tests

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
        Unit :a => "Returns a String" do ; X.new.a.assert.is_a?(String) ; end
        Unit :b => "Returns a String" do ; X.new.b.assert.is_a?(String) ; end
        Unit :c => "Returns a String" do ; X.new.c.assert.is_a?(String) ; end
      end
      TestCase Y do
        Unit :q => "Returns a String" do ; Y.new.q.assert.is_a?(String) ; end
      end
      """
    When I cd to "example"
    And I run "lemon -Ilib -v test/case_complete.rb"
    Then the stdout should contain "4 tests"
    And the stdout should contain "4 pass"
    And the stdout should contain "0 fail"
    And the stdout should contain "0 err"

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
        Unit :a => "Returns a String" do ; X.new.a.assert.is_a?(String) ; end
        Unit :b => "Returns a String" do ; X.new.b.assert.is_a?(Fixnum) ; end
        Unit :d => "Returns a String" do ; X.new.d.assert.is_a?(String) ; end
      end
      """
    When I cd to "example"
    And I run "lemon -Ilib -v test/case_complete.rb"
    Then the stdout should contain "3 tests"
    And the stdout should contain "1 pass"
    And the stdout should contain "1 fail"
    And the stdout should contain "1 err"

