module Lemon

  module DSL

    #
    module Subject

      # Setup is used to set things up for each unit test.
      # The setup procedure is run before each unit.
      #
      # @param [String] description
      #   A brief description of what the setup procedure sets-up.
      #
      def Setup(description=nil, &procedure)
        if procedure
          @subject = TestSubject.new(@test_case, description, &procedure)
        end
      end

      alias_method :setup, :Setup

      alias_method :Concern, :Setup
      alias_method :concern, :Setup

      alias_method :Subject, :Setup
      alias_method :subject, :Setup

      # Teardown procedure is used to clean-up after each unit test.
      #
      def Teardown(&procedure)
        @subject.teardown = procedure
      end

      alias_method :teardown, :Teardown

    end

  end

end
