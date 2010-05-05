module Lemon

  #
  class Snapshot
    include Enumerable

    #
    def self.capture
      o = new
      o.capture
      o
    end

    #
    attr :modules

    #
    def initialize
      @modules = {}
    end

    #
    def each(&block)
      modules.values.each(&block)
    end

    #
    def size
      modules.size
    end

    #
    def [](mod)
      @modules[mod]
    end

    #
    def []=(mod, ofmod)
      @modules[mod] = ofmod
    end

    #
    def capture
      sys = []
      ObjectSpace.each_object(Module) do |mod|
        @modules[mod] = OfModule.new(mod)
      end
      sys
    end

    #
    def to_a(public_only=true)
      modules.values.map{ |m| m.to_a(public_only) }.flatten
    end

    # Produce a hash based checklist that Coverage uses
    # to compare against tests and create a coverage report.
    def checklist(public_only=true)
      h = Hash.new{|h,k|h[k]={}}
      modules.values.each do |mod|
        mod.class_methods(public_only).each do |meth|
          h[mod.name]["::#{meth}"] = false
        end
        mod.instance_methods(public_only).each do |meth|
          h[mod.name]["#{meth}"] = false
        end
      end
      h
    end

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
    def clean!
      modules.each do |mod, ofmod|
        if ofmod.class_methods(false).empty? && ofmod.instance_methods(false).empty?
          modules.delete(mod)
        end
      end
    end

    #
    def filter(&block)
      c = Snapshot.new
      modules.each do |mod, ofmod|
        if block.call(ofmod)
          c[mod] = ofmod
        end
      end
      c
    end

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

        @public_class_methods    = base.public_methods(false)
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

  end

end
