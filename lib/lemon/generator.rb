module Lemon

  require 'lemon/coverage/analyzer'
  require 'lemon/coverage/source_parser'

  # TODO: Add option to add `require <file>` for each test file genetated.

  # Test Scaffold Generator.
  #
  class Generator

    # New Scaffold Generator.
    #
    # @option options [Array] :files
    #   Ruby scripts for which to generate tests.
    #
    # @option options [Array] :tests
    #   Test files that already exist.
    #
    # @option options [Array] :namespaces
    #   List of class/module names to limit scaffolding.
    #
    # @option options [Boolean] :private
    #   Include private methods in scaffolding.
    #
    # @option options [Symbol] :group
    #   Group by `:case` or by `:file`.
    #
    def initialize(options={})
      @files      = options[:files] || []
      @tests      = options[:tests] || []
      @group      = options[:group] || :case

      @namespaces = options[:namespaces]
      #@coverage   = options[:coverage]
      @private    = options[:private]
      @caps       = options[:caps]

      #if @namespaces
      #  @coverage ||= :all
      #else
      #  @coverage ||= :uncovered
      #end

      #@snapshot   = Snapshot.capture

      @analyzer   = CoverageAnalyzer.new(files + tests, options)
      @suite      = @analyzer.suite
    end

    #
    attr :files

    #
    attr :tests

    # Group tests by `:case` or `:file`.
    attr :group

    # List of class and module namespaces to limit scaffolding.
    attr :namespaces

    # Target coverage `:all`, `:uncovered` or `:covered`.
    #def coverage
    #  @coverage
    #end

    # Include private and protected methods.
    def private?
      @private
    end

    # Returns CoverageAnalyzer instance.
    def analyzer
      @analyzer
    end

    # Units in groups, by file or by case.
    def grouped_units
      case group
      when :case
        units_by_case
      when :file
        units_by_file
      else
        units_by_case # default ?
      end
    end

    # Generate test template(s).
    def generate
      render_map = {}

      if tests.empty?
        grouped_units.each do |group, units|
          units = filter(units)
          render_map[group] = render(units)
        end
      else
        uncovered_units = analyzer.uncovered
        grouped_units.each do |group, units|
          units = filter(units)
          units = units & uncovered_units
          render_map[group] = render(units)
        end
      #when :covered
      #  covered_units = analyzer.target.units
      #  grouped_units.each do |group, units|
      #    units = filter(units)
      #    units = units & covered_units
      #    map[group] = render(units)
      #  end
      #else
      #  #units = Snapshot.capture(namespaces).units
      #  #units = (units - @snapshot.units)
      end

      render_map
    end

    # TODO: If units knew which file they came from that would make
    #       the code more efficient b/c then we could group after all
    #       filtering instead of before.

    #
    def units_by_case
      units = []
      files.each do |file|
        units.concat SourceParser.parse_units(File.read(file))
      end
      units.group_by{ |u| u.namespace }
    end

    #
    def units_by_file
      map = {}
      files.each do |file|
        units = SourceParser.parse_units(File.read(file))
        map[file] = units
      end
      map
    end

    # Filter targets to include only specified namespaces.
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
        code << "#{term_case} #{mod} do"
        units.each do |unit|
          next unless private? or unit.public?
          if unit.function?
            code << "\n  #{term_class_method} :#{unit.method} do"
            code << "\n    test '' do"
            code << "\n    end"
            code << "\n  end"
          else
            code << "\n  #{term_method} :#{unit.method} do"
            code << "\n    test '' do"
            code << "\n    end"
            code << "\n  end"
          end
        end
        code << "\nend\n"
      end
      code.join("\n")
    end

    #
    def term_case
      @caps ? 'TestCase' : 'test_case'
    end

    #
    def term_class_method
      @caps ? 'ClassMethod' : 'class_method'
    end

    #
    def term_method
      @caps ? 'Method' : 'method'
    end

  end

end
