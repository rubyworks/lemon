module Lemon

  #
  class Coverage

    # Paths of ruby scripts to be covered.
    attr :paths

    # Conical snapshot of system (before loading libraries to be covered).
    attr :conical

    # New Coverage object.
    #
    #   Coverage.new('lib/', :public => true)
    #
    def initialize(paths, options={})
      @public = options[:public]

      @paths   = paths
      @conical = snapshot

      load_system
    end

    # Over use public methods for coverage.
    def public_only?
      @public
    end

    # Produce a coverage map.
    def coverage(suite)
      checklist = cover()
      suite.each do |testcase|
        testcase.testunits.each do |testunit|
          checklist[testcase.target.name][testunit.target.to_s] = true
        end
      end
      checklist
    end

    # Coverage template.
    def cover
      cover = {}
      system.each do |base|
        next if base.is_a?(Lemon::Test::Suite)
        cover[base.name] = {}
        base.public_instance_methods(false).each do |meth|
          cover[base.name][meth.to_s] = false
        end
        unless public_only?
          base.private_instance_methods(false).each do |meth|
            cover[base.name][meth.to_s] = false
          end
          base.protected_instance_methods(false).each do |meth|
            cover[base.name][meth.to_s] = false
          end
        end
      end
      cover
    end

    # Iterate over +paths+ and use #load to bring in all +.rb+ scripts.
    def load_system
      files = []
      paths.map do |path|
        if File.directory?(path)
          files.concat(Dir[File.join(path, '**', '*.rb')])
        else
          files.concat(Dir[path])
        end
      end
      files.each{ |file| load(file) }
    end

    # System to be covered. This takes a sanpshot of the system
    # and then removes the conical snapshot.
    def system
      snapshot - conical
    end

    # Produces a list of all existent Modules and Classes.
    def snapshot
      sys = []
      #ObjectSpace.each_object(Class) do |c|
      #  sys << c
      #end
      ObjectSpace.each_object(Module) do |m|
        sys << m
      end
      sys
    end

    # TODO: option to do only do what hasn't been covered thus far
    def generate(opts={})
      code = []
      system.each do |base|
        next if base.is_a?(Lemon::Test::Suite)
        code << "testcase #{base}"
        base.public_instance_methods(false).each do |meth|
          code << "\n  unit :#{meth} => '' do\n    pending\n  end"
        end
        unless public_only?
          base.private_instance_methods(false).each do |meth|
            code << "\n  unit :#{meth} => '' do\n    pending\n  end"
          end
          base.protected_instance_methods(false).each do |meth|
            code << "\n  unit :#{meth} => '' do\n    pending\n  end"
          end
        end
        code << "\nend\n"
      end
      code.join("\n")
    end

  end#class Coverage

end#module Lemon

