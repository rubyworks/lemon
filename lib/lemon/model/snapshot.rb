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
      #@modules = {}
      @units = units
    end

    #
    def each(&block)
      units.each(&block)
      #modules.values.each(&block)
    end

    #
    def size
      @units.size
      #modules.size
    end

    #
    def reset
      each{ |u| u.covered = false }
    end

    #
    #def [](mod)
    #  @modules[mod]
    #end

    #
    #def []=(mod, ofmod)
    #  @modules[mod] = ofmod
    #end

    #
    def capture(namespaces=nil)
      @units = []
      ObjectSpace.each_object(Module) do |mod|
        next if mod.name.empty?
        next if namespaces && !namespaces.any?{ |ns| /^#{ns}/ =~ mod.to_s }
        capture_module(mod)
        #@modules[mod] = OfModule.new(mod)
      end
    end

    def capture_module(mod)
      [:public, :protected, :private].each do |access|
        methods  = mod.__send__("#{access}_instance_methods", false)
        methods -= Object.__send__("#{access}_instance_methods", true)
        methods.each do |method|
          @units << Unit.new(mod, method, :access=>access)
        end

        methods  = mod.__send__("#{access}_methods", false)
        methods -= Object.__send__("#{access}_methods", true)
        methods.each do |method|
          @units << Unit.new(mod, method, :access=>access, :function=>true)
        end
      end

      #public_instance_methods    -= mod.public_instance_methods(false)
      #protected_instance_methods -= mod.protected_instance_methods(false)
      #private_instance_methods   -= mod.private_instance_methods(false)

      #public_instance_methods    -= Object.public_instance_methods
      #protected_instance_methods -= Object.protected_instance_methods
      #private_instance_methods   -= Object.private_instance_methods

      #public_instance_methods.each do |method|
      #  @units << Unit.new(mod, method)
      #end

      #protected_instance_methods.each do |method|
      #  @units << Unit.new(mod, method, :acccess=>:protected)
      #end

      #private_instance_methods.each do |method|
      #  @units << Unit.new(mod, method, :acccess=>:private)
      #end

      #public_methods    -= mod.public_methods(false)
      #protected_methods -= mod.protected_methods(false)
      #private_methods   -= mod.private_methods(false)

      #public_methods    -= Object.public_methods
      #protected_methods -= Object.protected_methods
      #private_methods   -= Object.private_methods

      #public_methods.each do |method|
      #  @units << Unit.new(mod, method, :function=>true)
      #end

      #protected_methods.each do |method|
      #  @units << Unit.new(mod, method, :acccess=>:protected, :function=>true)
      #end

      #private_methods.each do |method|
      #  @units << Unit.new(mod, method, :acccess=>:private, :function=>true)
      #end

      @units
    end

    #
    def to_a(public_only=true)
      @units #modules.values.map{ |m| m.to_a(public_only) }.flatten
    end

    # Produce a hash based checklist thap mod #.namet Coverage uses
    # to compare against tests and create a coverage report.
    #def checklist(public_only=true)
    #  h = Hash.new{|h,k|h[k]={}}
    #  modules.values.each do |mod|
    #    mod.class_methods(public_only).each do |meth|
    #      h[mod.name]["::#{meth}"] = false
    #    end
    #    mod.instance_methods(public_only).each do |meth|
    #      h[mod.name]["#{meth}"] = false
    #    end
    #  end
    #  h
    #end

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

=begin
    #
    def -(other)
      c = Snapshot.new
      modules.each do |mod, ofmod|
        c[mod] = ofmod.dup
      end
      other.modules.each do |mod, ofmod|
        if c[mod]
          c[mod].public_instance_methods -= ofmod.public_instance_methods
          c[mod].private_instance_methods -= ofmod.private_instance_methods
          c[mod].protected_instance_methods -= ofmod.protected_instance_methods

          c[mod].public_class_methods -= ofmod.public_class_methods
          c[mod].private_class_methods -= ofmod.private_class_methods
          c[mod].protected_class_methods -= ofmod.protected_class_methods
        end
      end
      c.clean!
      return c
    end


    #
    def <<(other)
      other.modules.each do |mod, ofmod|
        if self[mod]
          self[mod].public_instance_methods += ofmod.public_instance_methods
          self[mod].private_instance_methods += ofmod.private_instance_methods
          self[mod].protected_instance_methods += ofmod.protected_instance_methods

          self[mod].public_class_methods += ofmod.public_class_methods
          self[mod].private_class_methods += ofmod.private_class_methods
          self[mod].protected_class_methods += ofmod.protected_class_methods
        else
          self[mod] = ofmod.dup
        end
      end     
    end
=end

    #
    #def clean!
    #  modules.each do |mod, ofmod|
    #    if ofmod.class_methods(false).empty? && ofmod.instance_methods(false).empty?
    #      modules.delete(mod)
    #    end
    #  end
    #end

    #
    #def filter(&block)
    #  c = Snapshot.new
    #  modules.each do |mod, ofmod|
    #    if block.call(ofmod)
    #      c[mod] = ofmod
    #    end
    #  end
    #  c
    #end


=begin
    #
    class OfModule
      attr :base

      attr_accessor :public_instance_methods
      attr_accessor :protected_instance_methods
      attr_accessor :private_instance_methods

      attr_accessor :public_class_methods
      attr_accessor :protected_class_methods
      attr_accessor :private_class_methods

      #
      def initialize(base)
        @base = base

        @public_instance_methods    = base.public_instance_methods(false)
        @protected_instance_methods = base.protected_instance_methods(false)
        @private_instance_methods   = base.private_instance_methods(false)

        @public_class_methods    = base.methods(false)
        @protected_class_methods = base.protected_methods(false)
        @private_class_methods   = base.private_methods(false)
      end

      #
      def name
        @base.name
      end

      #
      def instance_methods(public_only=true)
        if public_only
          public_instance_methods
        else
          public_instance_methods + private_instance_methods + protected_instance_methods
        end
      end

      #
      def class_methods(public_only=true)
        if public_only
          public_class_methods
        else
          public_class_methods + private_class_methods + protected_class_methods
        end
      end

      #
      def to_a(public_only=true)
        class_methods(public_only).map{ |m| "#{name}.#{m}" } + instance_methods(public_only).map{ |m| "#{name}##{m}" }
      end
    end
=end

    # Snapshot Unit encapsulates a method, it's characteristics. It also has a
    # flag that can be used to mark whether it has been covered or not.
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

      #
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
        return :protected if proctected?
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

