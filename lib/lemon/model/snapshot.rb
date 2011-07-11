module Lemon

  # Snapshot is used to record the "unit picture" of the system
  # at a given moment.
  class Snapshot

    include Enumerable

    #
    def self.capture(namespaces=nil)
      o = new
      o.capture(namespaces)
      o
    end

    #
    attr :units

    #
    def initialize(units=[])
      @units = units
    end

    #
    def each(&block)
      units.each(&block)
    end

    #
    def size
      @units.size
    end

    #
    def reset
      each{ |u| u.covered = false }
    end

    # Select units by namespace (i.e. module or class).
    #def [](mod)
    #  @units.select{ |u| u.namespace == mod }
    #end

    #
    def capture(namespaces=nil)
      @units = []
      ObjectSpace.each_object(Module) do |mod|
        next if mod.nil? or mod.name.nil? or mod.name.empty?
        #next if namespaces and !namespaces.any?{ |ns| /^#{ns}(::|$)/ =~ mod.to_s }
        next if namespaces and !namespaces.any?{ |ns| ns.to_s == mod.to_s }
        capture_namespace(mod)
      end
    end

    #
    def capture_namespace(mod)
      ['', 'protected_', 'private_'].each do |access|
        methods  = mod.__send__("#{access}instance_methods", false)
        #methods -= Object.__send__("#{access}instance_methods", true)
        methods.each do |method|
          @units << Unit.new(mod, method, :access=>access)
        end

        methods  = mod.__send__("#{access}methods", false)
        #methods -= Object.__send__("#{access}methods", true)
        methods.each do |method|
          @units << Unit.new(mod, method, :access=>access, :function=>true)
        end
      end
      return @units
    end

    #
    def to_a
      @units
    end

    #
    def public_units
      @units.select{ |u| u.public? }
    end

    #
    def -(other)
      Snapshot.new(units - other.units)
    end

    #
    def +(other)
      Snapshot.new(units + other.units)
    end

    #
    def <<(other)
      @units.concat(other.units)
    end

    # Snapshot Unit encapsulates a method and it's various characteristics.
    class Unit

      # Clsss or module.
      attr :target

      # Method name.
      attr :method

      # Is the method a "class method", rather than an instance method.
      attr :function

      def initialize(target, method, props={})
        @target   = target
        @method   = method.to_sym
        @function = props[:function] ? true : false
        @covered  = props[:covered]

        if @function
          @private   = @target.private_methods.find{ |m| m.to_sym == @method }
          @protected = @target.protected_methods.find{ |m| m.to_sym == @method }
        else
          @private = @target.private_instance_methods.find{ |m| m.to_sym == @method }
          @protected = @target.protected_instance_methods.find{ |m| m.to_sym == @method }
        end
      end

      # Can be used to flag a unit as covered.
      attr_accessor :covered

      # Alternate name for target.
      def namespace
        @target
      end

      #
      def function?
        @function
      end

      # Method access is public?
      def public?
        !(@private or @protected)
      end

      # Method access is public?
      def private?
        @private
      end

      #
      def protected?
        @protected
      end

      #
      def access
        return :private if private?
        return :protected if protected?
        :public
      end

      # Marked as covered?
      def covered?
        @covered
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

end
