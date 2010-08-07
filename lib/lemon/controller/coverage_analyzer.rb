require 'lemon/model/snapshot'
require 'lemon/model/test_suite'
#require 'lemon/main'
#require 'lemon/view/coversheets/outline'

module Lemon

  #
  class CoverageAnalyzer

    #
    attr :suite

    # Paths of lemon tests and/or ruby scripts to be compared and covered.
    # This can include directories too, in which case all .rb scripts below
    # then directory will be included.
    attr :files

    ## Conical snapshot of system (before loading libraries to be covered).
    #attr :canonical

    # Report format.
    attr :format

    #
    attr :namespaces

    ## New Coverage object.
    ##
    ##   Coverage.new('lib/', :MyApp, :public => true)
    ##
    #def initialize(suite_or_files, namespaces=nil, options={})
    #  @namespaces = namespaces || []
    #  case suite_or_files
    #  when Test::Suite
    #    @suite = suite_or_files
    #    @files = suite_or_files.files
    #  else
    #    @suite = Test::Suite.new(suite_or_files)
    #    @files = suite_or_files
    #  end
    #  #@canonical = @suite.canonical
    #  @public    = options[:public]
    #end

    # New Coverage object.
    #
    #   CoverageAnalyzer.new(suite, :MyApp, :public => true)
    #
    def initialize(test_files, options={})
      @files = test_files

      @namespaces = [options[:namespaces]].flatten.compact
      @private    = options[:private]
      @format     = options[:format]

      @reporter   = reporter_find(@format)

      @canonical = Snapshot.capture #system #@suite.canonical

      @suite = Lemon::TestSuite.new(test_files, :cover=>true)  #@suite = suite
    end

    #
    def canonical
      @canonical #= Snapshot.capture
    end

    #
    def suite=(suite)
      raise ArgumentError unless TestSuite === suite
      @suite = suite
    end

    # Over use public methods for coverage.
    def public_only?
      !@private
    end

    #
    def private?
      @private
    end

    #
    def each(&block)
      units.each(&block)
    end

    # Produce units list from the test suite.
    def units
      @units ||= (
        list = []
        suite.each do |testcase|
          testcase.testunits.each do |unit|
            list << Snapshot::Unit.new(
              unit.testcase.target,
              unit.target,
              :function=>unit.meta?
            )
          end
        end
        list
      )
    end

    #
    def targets
      @targets ||= units.map{ |u| u.namespace }.uniq
    end

    #
    def target_system
      @target_system ||= system(*targets)
    end

    #
    #def target_units
    #  @target_units ||= target_system.units
    #end


    # Produce a coverage map.
    #def checklist
    #  list = system.checklist
    #  suite.each do |testcase|
    #    testcase.testunits.each do |testunit|
    #      list[testcase.target.name][testunit.key] = true
    #    end
    #  end
    #  list
    #end

    # Produce a coverage checklist.
    #def checklist
    #  suite.each do |testcase|
    #    testcase.testunits.each do |testunit|
    #      list[testcase.target.name][testunit.key] = true
    #    end
    #  end
    #  list
    #end

    #
    def covered
      units
    end

    #
    def uncovered
      #system.units - units
      @uncovered
    end

    #
    def undefined
      #units - system.units
      @undefined      
    end

    # List of modules/classes not covered.
    def uncovered_cases
      @uncovered_cases
    end

    #
    def calculate
      @units = (
        list = []
        suite.each do |testcase|
          testcase.testunits.each do |unit|
            list << Snapshot::Unit.new(
              unit.testcase.target,
              unit.target,
              :function=>unit.function?
            )
          end
        end
        list
      )

      @uncovered = target_system.units - @units

      @undefined = @units - target_system.units

      @uncovered_cases = (
        list = filter(system.units - (target_system.units + canonical.units))
        list.map{ |u| u.namespace }.uniq
        list
      )
    end

    #def load_covered_files
    #  suite.load_covered_files
    #end

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

    #    # Snapshot of System to be covered. This takes a current snapshot
    #    # of the system and removes the canonical snapshot or filters out
    #    # everything but the selected namespace.
    #    def system
    #      if namespaces.empty?
    #        snapshot - canonical
    #      else
    #        (snapshot - canonical).filter do |ofmod|
    #          namespaces.any?{ |n| ofmod.name.start_with?(n.to_s) }
    #        end
    #      end
    #    end

    #
    #def system
    #  if namespaces.empty?
    #    suite.coverage
    #  else
    #    suite.coverage.filter do |ofmod|
    #      namespaces.any?{ |n| ofmod.name.start_with?(n.to_s) }
    #    end
    #  end
    #end

    #
    def system(*namespaces)
      namespaces = nil if namespaces.empty?
      Snapshot.capture(namespaces)
    end

    # Get a snapshot of the system.
    #def snapshot
    #  Snapshot.capture
    #end

    #
    def filter(units)
      return units if namespaces.nil? or namespaces.empty?
      #units = units.reject do |u|
      #  /^Lemon::/ =~ u.namespace.to_s
      #end
      units = units.select do |u|
        namespaces.any? do |ns|
          /^#{ns}/ =~ u.namespace.to_s
        end
      end
      units
    end

    #
    def render
      reporter.render
    end

    # All output is handled by a reporter.
    def reporter
      @reporter ||= reporter_find(format)
    end

    #
    def reporter_find(format)
      format = format ? format.to_s.downcase : 'outline'
      format = reporter_list.find do |name|
        /^#{format}/ =~ name
      end
      raise "unsupported format" unless format
      require "lemon/view/cover_reports/#{format}"
      reporter = Lemon::CoverReports.const_get(format.capitalize)
      reporter.new(self)
    end

    #
    def reporter_list
      Dir[File.dirname(__FILE__) + '/../view/cover_reports/*.rb'].map do |rb|
        File.basename(rb).chomp('.rb')
      end
    end

  end#class Coverage

end#module Lemon

