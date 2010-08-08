require 'lemon/model/snapshot'
require 'lemon/model/test_suite'
#require 'lemon/main'
#require 'lemon/view/coversheets/outline'

module Lemon

  #
  class CoverageAnalyzer

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
      @canonical  = Snapshot.capture #system #@suite.canonical
      @suite      = Lemon::TestSuite.new(test_files, :cover=>true)  #@suite = suite
    end

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
    def namespaces
      @namespaces
    end

    #
    #def target_units
    #  @target_units ||= target_system.units
    #end



    # Trigger a full set of calculations.
    def calculate
      uncovered_cases # that should be all it takes
    end

    #
    def covered_units
      @covered_units ||= (
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
    end

    #
    def covered_namespaces
      @covered_namespaces ||= covered_units.map{ |u| u.namespace }.uniq
    end

    #
    def target_namespaces
      @target_namespaces ||= filter(covered_namespaces)
    end

    # Target system snapshot.
    def target
      @target ||= Snapshot.capture(target_namespaces)
    end

    # Current system snapshot.
    def current
      @current ||= Snapshot.capture
    end

    #
    def uncovered_units
      @uncovered_units ||= target.units - covered_units
    end

    #
    def undefined_units
      @undefined_units ||= covered_units - target.units   
    end

    # List of modules/classes not covered.
    def uncovered_cases
      @uncovered_cases ||= (
        list = current.units - (target.units + canonical.units)
        list = list.map{ |u| u.namespace }.uniq
        list
      )
    end

    #
    alias_method :covered,   :covered_units
    alias_method :uncovered, :uncovered_units
    alias_method :undefined, :undefined_units

    # Reset coverage data for recalcuation.
    def reset!
      @covered_units      = nil
      @covered_namespaces = nil
      @target_namespaces  = nil
      @uncovered_units    = nil
      @undefined_units    = nil
      @target             = nil
      @current            = nil
    end

    # Iterate over covered units.
    def each(&block)
      covered_units.each(&block)
    end

    # Number of covered units.
    def size
      covered_units.size
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

  private

    #
    def system(*namespaces)
      namespaces = nil if namespaces.empty?
      Snapshot.capture(namespaces)
    end

    # Get a snapshot of the system.
    #def snapshot
    #  Snapshot.capture
    #end

    # Filter namespaces.
    def filter(ns)
      return ns if namespaces.nil? or namespaces.empty?
      #units = units.reject do |u|
      #  /^Lemon::/ =~ u.namespace.to_s
      #end
      ns.select do |u|
        namespaces.any?{ |ns| /^#{ns}(::|$)/ =~ u.namespace.to_s }
      end
    end

    #
    def filter_units(units)
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

  public

    #
    def render
      reporter.render
    end

    # All output is handled by a reporter.
    def reporter
      @reporter ||= reporter_find(format)
    end

  private

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

