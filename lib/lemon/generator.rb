module Lemon

  require 'lemon/coverage/analyzer'

  # Test Scaffold Generator.
  #
  #--
  # TODO: The options  for selecting all, covered and uncovered still
  #       need some work.
  #++
  class Generator

    # New Scaffold Generator.
    #
    def initialize(files, options={})
      @files      = files

      @coverage   = CoverageAnalyzer.new(files, options)
      @suite      = @coverage.suite

      @namespaces = options[:namespaces]
      @private    = options[:private]

      @covered    = options[:covered]
      @uncovered  = options[:uncovered]

      @all        = options[:all]

      if @namespaces
        unless @covered or @uncovered
          @all = true 
        end
      end

    end

    # Returns CoverageAnalyzer instance.
    def coverage
      @coverage
    end

    #
    def namespaces
      @namespaces
    end

    #
    def all?
      @all
    end

    #
    def covered?
      @covered
    end

    # Include only uncovered methods.
    def uncovered?
      @uncovered
    end

    # Include private and protected methods.
    def private?
      @private
    end

    # Generate test template(s).
    def generate
      if all?
        generate_all
      elsif uncovered?
        generate_uncovered
      else
        generate_target
      end
    end

    #
    def generate_target
      render(filter(coverage.target.units))
    end

    #
    def generate_uncovered
      render(filter(coverage.uncovered))
    end

    # Generate code template.
    def generate_all
      render(Snapshot.capture(namespaces).units)
    end

    #
    def filter(units)
      return units if namespaces.nil? or namespaces.empty?
      units.select do |u|
        namespaces.any? do |ns|
          /^#{ns}/ =~ u.namespace.to_s
        end
      end
    end

    # Generate code template.
    def render(units)
      code = []
      mods = units.group_by{ |u| u.namespace }
      mods.each do |mod, units|
        if Class === mod
          code << "TestClass #{mod} do"
        else
          code << "TestModule #{mod} do"
        end
        units.each do |unit|
          next unless private? or unit.public?
          if unit.function?
            code << "\n  ClassMethod :#{unit.method} do"
            code << "\n    Test '' do"
            code << "\n    end"
            code << "end"
          else
            code << "\n  Method :#{unit.method} do"
            code << "\n    Test '' do"
            code << "\n    end"
            code << "\n  end"
          end
        end
        code << "\nend\n"
      end

      code.join("\n")
    end

  end

end
