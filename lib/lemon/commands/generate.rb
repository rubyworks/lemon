module Lemon
module Commands

  # Lemon Generate Command-line tool.
  #
  class Generate < Command
    require 'lemon/coverage'

    #
    def self.subcommand
      'generate' #['-g', '--generate']
    end

    # Initialize and run.
    def self.run
      new.run
    end

    # New Command instance.
    def initialize
      @requires    = []
      @includes    = []
      @namespaces  = []
      @public_only = false
      @uncovered   = false
    end

    # TODO: Support output ? perhaps complex scaffolding
    #attr_accessor :output

    #
    attr_accessor :public_only

    #
    attr_accessor :uncovered

    #
    def public_only?
      @public_only
    end

    #
    def uncovered_only?
      @uncovered
    end

    # Get or set librarires to pre-require.
    def requires(*paths)
      @requires.concat(paths) unless paths.empty?
      @requires
    end

    # Get or set paths to include in $LOAD_PATH.
    def includes(*paths)
      @includes.concat(paths) unless paths.empty?
      @includes
    end

    #
    def namespaces(*names)
      @namespaces.concat(names) unless names.empty?
      @namespaces
    end

    # Instance of OptionParser.
    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "lemon generate [OPTIONS]"
        opt.separator("Generate unit test scaffolding.")
        opt.on("--namespace", "-n [NAME]", "limit tests to this namespace") do |name|
          namespaces(name)
        end
        opt.on("--public", "-p", "only include public methods") do
          self.public_only = true
        end
        opt.on("--uncovered", "-u", "only include uncovered methods") do
          self.uncovered = true
        end
        #opt.on("--output", "-o [PATH]", "output directory") do |path|
        #  self.output = path
        #end
        opt.on("-r [FILES]" , "library files to require") do |files|
          files = files.split(/[:;]/)
          requires(*files)
        end
        opt.on("-I [PATH]" , "include in $LOAD_PATH") do |path|
          path = path.split(/[:;]/)
          includes(*path)
        end
        opt.on("--debug" , "turn on debugging mode") do
          $DEBUG = true
        end
        opt.on_tail("--help", "-h", "show this help message") do
          puts opt
          exit
        end
      end
    end

    # Generate test skeletons.
    def run
      parser.parse!

      test_files = ARGV.dup

      includes.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      suite = Lemon::Test::Suite.new(test_files, :cover=>true)
      cover = Lemon::Coverage.new(suite, namespaces, :public=>public_only?)
      #cover  = Lemon::Coverage.new([], namespaces, :public=>public_only?, :uncovered=>uncovered_only?)

      if uncovered_only?
        puts cover.generate_uncovered #(output)
      else
        puts cover.generate #(output)
      end
    end

  end

end
end

