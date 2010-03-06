module Lemon

  #
  class Coverage

    # Paths of lemon tests and/or ruby scripts to be compared and covered.
    # This can include directories too, in which case all .rb scripts below
    # then directory will be included.
    attr :files

    # Conical snapshot of system (before loading libraries to be covered).
    attr :canonical

    #
    attr :namespaces

    # New Coverage object.
    #
    #   Coverage.new('lib/', :MyApp, :public => true)
    #
    def initialize(suite_or_files, namespaces=nil, options={})
      @namespaces = namespaces || []
      case suite_or_files
      when Test::Suite
        @suite = suite_or_files
        @files = suite_or_files.files
      else
        @suite = Test::Suite.new(suite_or_files)
        @files = suite_or_files
      end
      @canonical = @suite.canonical
      @public    = options[:public]
    end

    #
    def suite=(suite)
      raise ArgumentError unless Test::Suite === suite
      @suite = suite
    end

    # Over use public methods for coverage.
    def public_only?
      @public
    end

    #
    def each(&block)
      coverage.each(&block)
    end

    # Produce a coverage map.
    def coverage(suite=nil)
      suite = suite || @suite
      checklist = self.cover
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

        # instance methods
        base.public_instance_methods(false).each do |meth|
          cover[base.name][meth.to_s] = false
        end
        # meta methods
        (base.public_methods(false) - Object.public_methods(false)).each do |meth|
          cover[base.name][meth.to_s] = false
        end

        unless public_only?
          # instance methods
          base.private_instance_methods(false).each do |meth|
            cover[base.name][meth.to_s] = false
          end
          base.protected_instance_methods(false).each do |meth|
            cover[base.name][meth.to_s] = false
          end
          # meta methods
          (base.private_methods(false) - Object.private_methods(false)).each do |meth|
            cover[base.name][meth.to_s] = false
          end
          (base.protected_methods(false) - Object.protected_methods(false)).each do |meth|
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
        snapshot - canonical
      else
        snapshot.select do |m|
          namespaces.any?{ |n| m.name.start_with?(n) }
        end
      end
    end

    # TODO: combine with coverage to provided option to only do what hasn't been covered thus far.
    # TODO: support output directory

    def generate(output=nil)
      code = []
      system.each do |base|
        next if base.is_a?(Lemon::Test::Suite)
        code << "TestCase #{base} do"
        base.public_instance_methods(false).each do |meth|
          code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
        end
        unless public_only?
          base.private_instance_methods(false).each do |meth|
            code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
          end
          base.protected_instance_methods(false).each do |meth|
            code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
          end
        end
        code << "\nend\n"
      end
      code.join("\n")
    end

    #
    def generate_uncovered(output=nil)
      code = []
      coverage.each do |base, methods|
        next if /Lemon::Test::Suite/ =~ base.to_s
        code << "TestCase #{base} do"
        methods.each do |meth, covered|
          next if covered
          code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
        end
        #base.public_instance_methods(false).each do |meth|
        #  code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #end
        #unless public_only?
        #  base.private_instance_methods(false).each do |meth|
        #    code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #  end
        #  base.protected_instance_methods(false).each do |meth|
        #    code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #  end
        #end
        code << "\nend\n"
      end
      code.join("\n")
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

  end#class Coverage

end#module Lemon

