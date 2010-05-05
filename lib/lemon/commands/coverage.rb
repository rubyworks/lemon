module Lemon
module Commands

  # Lemon Coverage Command-line tool.
  class Coverage < Command
    require 'yaml'
    require 'lemon/coverage'

    def self.subcommand
      'coverage' #['-c', '--coverage']
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
        opt.banner = "lemon coverage [OPTIONS]"
        opt.separator("Produce test coverage report.")
        opt.on('--namespace', '-n [NAME]', "limit coverage to this namespace") do |name|
          namespaces(name)
        end
        opt.on('--public', '-p', "only include public methods") do
          self.public_only = true
        end
        opt.on("-r [FILES]" , 'library files to require') do |files|
          files = files.split(/[:;]/)
          requires(*files)
        end
        opt.on("-I [PATH]" , 'include in $LOAD_PATH') do |path|
          path = path.split(/[:;]/)
          includes(*path)
        end
        opt.on("--debug" , 'turn on debugging mode') do
          $DEBUG = true
        end
        opt.on_tail('--help', '-h', 'show this help message') do
          puts opt
          exit
        end
      end
    end

    #
    def run
      parser.parse!

      test_files = ARGV.dup
      load_files = []

      includes.each do |path|
        $LOAD_PATH.unshift(path)
      end

      requires.each{ |path| require(path) }

      suite = Lemon::Test::Suite.new(test_files)
      coverage = Lemon::Coverage.new(suite, namespaces, :public => public_only?)
      coverage.canonical!
      coverage.load_covered_files

      puts coverage.coverage.to_yaml
    end

  end

end
end

