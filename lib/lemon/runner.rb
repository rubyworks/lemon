require 'ae'
require 'ae/expect'

module Test

  #
  class Suite
    attr :testcases

    def initialize(*files)
      @files     = files
      @testcases = []
      files.each do |file|
        load(file)
      end
    end

    def load(file)
      instance_eval(File.read(file))
    end

    def testcase(target_class, &block)
      testcases << Case.new(target_class, &block)
    end

    def each(&block)
      @testcases.each(&block)
    end
  end

  #
  class Case
    attr :testunits

    def initialize(target_class, &block)
      @target_class = target_class
      @testunits = []
      instance_eval(&block)
    end

    def unit(target_method, &block)
      @testunits << Unit.new(target_method, &block)
    end

    def each(&block)
      @testunits.each(&block)
    end
  end

  #
  class Unit
    attr :concerns

    def initialize(target_method, &block)
      @target_method = target_method
      @concerns = []
      instance_eval(&block)
    end

    def concern(description, &block)
      @concerns << Concern.new(description, &block)
    end

    def each(&block)
      @concerns.each(&block)
    end
  end

  #
  class Concern
    attr :description

    def initialize(description, &block)
      @description = description
      @testblock   = block
    end

    def call
      @testblock.call
    end
  end

  #
  class Runner

    def initialize(suite)
      @suite    = suite
      @failures = []
      @errors   = []
    end

    def run
      @suite.each do |testcase|
        testcase.each do |testunit|
          testunit.each do |concern|
            begin
              concern.call
            rescue Assertion => err
              reporter.puts err
              @failures << err
            rescue => err
              reporter.puts err
              @errors << err
            end
          end
        end
      end
    end

    #
    def reporter
      $stdout
    end

  end

end

