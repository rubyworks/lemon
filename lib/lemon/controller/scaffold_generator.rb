require 'lemon/controller/coverage_analyzer'

module Lemon

  #
  class ScaffoldGenerator

    # New Scaffold Generator.
    #
    def initialize(suite, options={})
      @suite = suite

      @coverage = CoverageAnalyzer.new(suite, options)

      @namespaces = options[:namespaces]
      @private    = options[:private]
      #@covered    = options[:covered]
      @uncovered  = options[:uncovered]

      @files = suite.files
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
      if covered?
        generate_covered
      elsif uncovered?
        generate_uncovered
      else
        generate_all
      end
    end

    #
    def generate_covered
      render(filter(coverage.units))
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
