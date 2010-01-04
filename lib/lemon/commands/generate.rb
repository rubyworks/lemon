module Lemon
module Commands

  # Lemon Generate Command-line tool.
  class Generate < Command
    require 'lemon/coverage'

    #
    def self.options
      ['-g', '--generate']
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
    end

    #
    attr_accessor :output

    #
    attr_accessor :public_only

    #
    def public_only?
      @public_only
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

    # Get or set paths to include in $LOAD_PATH.
    def namespaces(*names)
      @namespaces.concat(names) unless names.empty?
      @namespaces
    end

    # Instance of OptionParser.
    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "lemon -g [OPTIONS]"
        opt.separator("Generate test scaffolding.")
        opt.on("--namespace", "-n [NAME]", "include namespace") do |name|
          namespaces(name)
        end
        opt.on("--public", "-p", "only include public methods") do
          self.public_only = true
        end
        opt.on("--output", "-o [PATH]", "output directory") do |path|
          self.output = path
        end
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

      includes.each do |path|
        $LOAD_PATHS.unshift(path)
      end

      requires.each{ |path| require(path) }

      cover  = Lemon::Coverage.new([], namespaces, :public=>public_only?)
      suite  = Lemon::Test::Suite.new(*test_files)
      puts cover.generate(output) #(suite).to_yaml
    end

  end

end
end

