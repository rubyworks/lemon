module Lemon

  class TestScope < World

    #
    def initialize(testcase)
      @_testcase = testcase

      extend testcase.domain
    end

  end

end
