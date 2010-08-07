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
    def initialize(suite, options={})
      @suite = suite

      @namespaces = [options[:namespaces]].flatten.compact
      @private    = options[:private]
      @format     = options[:format]

      @files = suite.files

      #@canonical = @suite.canonical
    end

    ##
    #def canonical!
    #  @canonical = Snapshot.capture
    #end

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
      system.units - units
    end

    #
    def undefined
      units - system.units
    end


    #
#    def format(type)
#      coversheet = nil
#      case type
#      when :verbose
#        puts checklist.to_yaml
#     else
#        #coversheet = CoverSheet::Outline.new(self)
#        #coversheet.coverage_finished
#        reporter.coverage_finished
#      end
#    end

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

    # List of modules/classes not covered.
    def uncovered_cases
      uncovered.map{ |u| u.namespace }.uniq
      #c = suite.coverage.map{ |ofmod| ofmod.base }
      #a = suite.testcases.map{ |tc| tc.target }
      #c - a
    end

=begin
    # List of methods not covered by covered cases.
    def uncovered_units
      @calculated ||= calculate_coverage
      @uncovered_units
    end

    #
    def undefined_units
      @calculated ||= calculate_coverage
      @undefined_units
    end

    #
    def calculate_coverage
      clist = []
      tlist = []
      suite.testcases.each do |tc|
        mod = tc.target

        metaunits, units = *tc.testunits.partition{ |u| u.meta? }

        units.map!{ |u| u.fullname }
        metaunits.map!{ |u| u.fullname }

        tlist = tlist | units
        tlist = tlist | metaunits

        if system[mod]
          meths = system[mod].instance_methods.map{ |m| "#{mod}##{m}" }
          metameths = system[mod].class_methods.map{ |m| "#{mod}.#{m}" }

          clist = clist | meths
          clist = clist | metameths
        end
      end
#p clist
#p tlist
      @uncovered_units = clist - tlist
      @undefined_units = tlist - clist
    end
=end

    #
    def system
      if namespaces.empty?
        suite.coverage
      else
        suite.coverage.filter do |ofmod|
          namespaces.any?{ |n| ofmod.name.start_with?(n.to_s) }
        end
      end
    end

    # Get a snapshot of the system.
    def snapshot
      Snapshot.capture
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

