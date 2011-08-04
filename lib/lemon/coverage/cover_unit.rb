module Lemon

  # Unit of coverage, ecapsulates a method, it's characteristics and a flag
  # as to whether it has been covered or not.
  class CoverUnit

    attr :target
    attr :method
    attr :function

    def initialize(target, method, props={})
      @target   = target
      @method   = method.to_sym
      @function = props[:function] ? true : false
      @covered  = props[:covered]

      if @function
        @private = !@target.public_methods.find{ |m| m.to_sym == @method }
      else
        @private = !@target.public_instance_methods.find{ |m| m.to_sym == @method }
      end
    end

    # Method access is private or protected?
    def private?
      @private
    end

    # Marked as covered?
    def covered?
      @covered
    end

    #
    def function?
      @function
    end

    #
    def hash
      @target.hash ^ @method.hash ^ @function.hash
    end

    #
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
      return false unless function == other.function
      return true
    end

    def inspect
      "#{target}#{function ? '.' : '#'}#{method}"
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
