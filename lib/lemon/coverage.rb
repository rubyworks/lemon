module Lemon

  #
  class Coverage

    # Paths of lemon tests and/or ruby scripts to be compared and covered.
    # This can include directories too, in which case all .rb scripts below
    # then directory will be included.
    attr :files

    # Conical snapshot of system (before loading libraries to be covered).
    attr :conical

    #
    attr :namespaces

    # New Coverage object.
    #
    #   Coverage.new('lib/', :MyApp, :public => true)
    #
    def initialize(files, namespaces=nil, options={})
      @namespaces = namespaces || []

      @files   = files
      @conical = snapshot

      @public  = options[:public]

      # this must come after concial snapshot
      @suite   = Test::Suite.new(files)
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
      cover = Hash.new{|h,k|h[k]={}}
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
    #def load_system
    #  files = []
    #  paths.map do |path|
    #    if File.directory?(path)
    #      files.concat(Dir[File.join(path, '**', '*.rb')])
    #    else
    #      files.concat(Dir[path])
    #    end
    #  end
    #  files.each{ |file| load(file) }
    #end

    # System to be covered. This takes a sanpshot of the system
    # and then removes the conical snapshot, and then filters out
    # the namespace.
    #
    # TODO: Perhaps get rid of the conical subtraction and require a namespace?
    def system
      if namespaces.empty?
        snapshot - conical
      else
        snapshot.select do |m|
          namespaces.any?{ |n| m.name.start_with?(n) }
        end
      end
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

    # TODO: combine with coverage to provided option to do only do what hasn't been covered thus far.
    # TODO: support output directory

    def generate(output=nil)
      code = []
      system.each do |base|
        next if base.is_a?(Lemon::Test::Suite)
        code << "TestCase #{base} do"
        base.public_instance_methods(false).each do |meth|
          code << "\n  Unit :#{meth} => '' do\n    pending\n  end"
        end
        unless public_only?
          base.private_instance_methods(false).each do |meth|
            code << "\n  Unit :#{meth} => '' do\n    pending\n  end"
          end
          base.protected_instance_methods(false).each do |meth|
            code << "\n  Unit :#{meth} => '' do\n    pending\n  end"
          end
        end
        code << "\nend\n"
      end
      code.join("\n")
    end

  end#class Coverage

end#module Lemon

