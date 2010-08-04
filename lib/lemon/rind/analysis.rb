require 'lemon/rind/report'

module Lemon

  #
  class Analysis

    #
    def initialize(trace, options={})
      @trace   = trace

      @private = options[:private]
    end

    #
    def log
      @trace.log
    end
    
    #
    def targets
      @trace.targets.map do |t|
        eval(t, TOPLEVEL_BINDING)
      end
    end

    #
    def private?
      @private
    end

    #
    def chart
      @chart ||= (
        chart = prechart
        log.each do |object, method|
          unit = Unit.new(object.class, method)
          chart[unit] = true
        end
        chart
      )
    end

    #
    def prechart
      chart = {}
      targets.each do |target|
        target.instance_methods(false).each do |meth|
          unit = Unit.new(target, meth)
          chart[unit] = false
        end

        target.methods(false).each do |meth|
          unit = Unit.new(target, meth, :function=>true)
          chart[unit] = false
        end

        if private?
          target.protected_instance_methods(false).each do |meth|
            unit = Unit.new(target, meth, :access=>:protected)
            chart[unit] = false
          end
          target.private_instance_methods(false).each do |meth|
            unit = Unit.new(target, meth, :access=>:private)
            chart[unit] = false
          end

          target.protected_methods(false).each do |meth|
            unit = Unit.new(target, meth, :access=>:protected, :function=>true)
            chart[unit] = false
          end
          target.private_methods(false).each do |meth|
            unit = Unit.new(target, meth, :access=>:private, :function=>true)
            chart[unit] = false
          end
        end
      end
      chart
    end

    #
    #def save(logdir)
    #  Report.new(chart).save(logdir)
    #end

  end

  #
  class Unit
    attr :target
    attr :method
    attr :function
    attr :access

    def initialize(target, method, attrs={})
      @target   = target
      @method   = method.to_sym
      @function = attrs[:function] ? true : false
      @access   = attrs[:access] || :public
    end
    
    def hash
      @target.hash ^ @method.hash ^ @function.hash
    end

    def to_s
      if @function
        "#{@target}.#{@method}"
      else
        "#{@target}##{@method}"
      end
    end
    alias to_str to_s

    def eql?(other)
      return false unless Unit === other
      return false unless target == other.target
      return false unless method == other.method
      #return false unless function == other.function
      return true
    end

    def inspect

    end

    def <=>(other)
      c = (target.name <=> other.target.name)
      return c unless c == 0
      return -1 if function  && !other.function
      return  1 if !function && other.function
      method.to_s <=> other.method.to_s
    end
  end

end

