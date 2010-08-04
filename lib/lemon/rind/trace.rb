require 'tracepoint'
require 'lemon/rind/analysis'

module Lemon

  #
  class Trace

    #
    attr :targets

    #
    attr :log

    #
    def initialize(targets, options={})
      @targets = targets.empty? ? nil : targets
      @options = options
      @log = []
    end

    #
    def setup
      tracker = self
      TracePoint.trace do |tp|
        #puts "#{tp.self.class}\t#{tp.callee}\t#{tp.event}\t#{tp.return?}"
        if tracker.target?(tp.self.class)
          tracker.log << [tp.self, tp.callee]
        end
      end
    end

    #
    def target?(mod)
      return true if targets.nil?
      targets.find do |target|
        begin
          target_class = eval(target, TOPLEVEL_BINDING) #Object.const_get(target)
        rescue
          nil
        else
          target_class == mod
        end
      end
    end

    #
    def activate
      setup
      TracePoint.activate
    end

    #
    def deactivate
      TracePoint.deactivate
    end

    #
    def to_analysis
      Analysis.new(self, @options)
    end

  end

end

