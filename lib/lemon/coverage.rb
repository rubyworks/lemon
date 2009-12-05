module Lemon

  #
  class Coverage

    attr :paths

    #
    def initialize(*paths)
      @paths   = paths
      @conical = snapshot
      load_system
    end

    #
    def coverage(suite)
      checklist = cover()
      suite.each do |test_case|
        test_case.each do |test_unit|
          checklist[test_case.test_class.name][test_unit.test_method.to_s] = true
        end
      end
      checklist
    end

    #
    def cover
      cover = {}
      system.each do |base|
        next if base.is_a?(Lemon::Test::Suite)
        cover[base.name] = {}
        base.public_instance_methods(false).each do |meth|
          cover[base.name][meth.to_s] = false
        end
        base.private_instance_methods(false).each do |meth|
          cover[base.name][meth.to_s] = false
        end
        base.protected_instance_methods(false).each do |meth|
          cover[base.name][meth.to_s] = false
        end
      end
      cover
    end

    #
    def load_system
      files = []
      paths.map do |path|
        if File.directory?(path)
          files.concat(Dir[File.join(path, '**', '*.rb')])
        else
          files << path
        end
      end
      files.each{ |file| load(file) }
    end

    #
    def system
      snapshot - @conical
    end

    #
    def snapshot
      sys = []
      ObjectSpace.each_object(Class) do |c|
        sys << c
      end
      ObjectSpace.each_object(Module) do |m|
        sys << m
      end
      sys
    end

  end

end

