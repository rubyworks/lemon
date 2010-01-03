module Lemon

  # = Reporter Base Class
  class Reporter

    #
    def self.factory(format, runner)
      format = format.to_sym if format
      case format
      when :verbose
        Reporters::Verbose.new(runner)
      else
        Reporters::DotProgress.new(runner)
      end
    end

    def initialize(runner)
      @runner = runner
    end

    #
    attr :runner

    #
    def report_start(suite)
    end

    def report_concern(concern)
    end

    def report_success(testunit)
    end

    def report_failure(testunit, exception)
    end

    def report_error(testunit, exception)
    end

    def report_finish
    end

    private

    def successes ; runner.successes ; end
    def failures  ; runner.failures  ; end
    def errors    ; runner.errors    ; end
    def pendings  ; runner.pendings  ; end

  end

end
