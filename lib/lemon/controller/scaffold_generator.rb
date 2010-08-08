require 'lemon/controller/coverage_analyzer'

module Lemon

  #
  class ScaffoldGenerator

    # New Scaffold Generator.
    #
    def initialize(files, options={})
      @files      = files

      @coverage   = CoverageAnalyzer.new(files, options)
      @suite      = @coverage.suite

      @namespaces = options[:namespaces]
      @private    = options[:private]
      @uncovered  = options[:uncovered]
      @all        = options[:all]
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
        code << "TestCase #{mod} do"
        units.each do |unit|
          next unless private? or unit.public?
          if unit.function?
            code << "\n  MetaUnit :#{unit.method} => '' do\n\n  end"
          else
            code << "\n  Unit :#{unit.method} => '' do\n\n  end"
          end
        end
        code << "\nend\n"
      end

      code.join("\n")
    end

  end

end
