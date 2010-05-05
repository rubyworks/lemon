module Lemon
module Commands

  # Lemon Test Command-line tool.
  class Test < Command
    require 'lemon/runner'

    def self.subcommand
      'test' #['-t', '--test']
    end

    # Initialize and run.
    def self.run
      new.run
    end

    # New Command instance.
    def initialize
      @format      = nil
      @coverage    = false
      @requires    = []
      @includes    = []
    end

    #
    attr_accessor :format
    attr_accessor :coverage

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

    # Instance of OptionParser.
    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "lemon [options] [test-files ...]"
        opt.separator("Run unit tests.")
        opt.separator("OPTIONS:")
        opt.on('--coverage', '-c', "include coverage informarton") do
          self.coverage = true
        end
        opt.on('--verbose', '-v', "select verbose report format") do |type|
          self.format = :verbose
        end
        opt.on('--outline', '-o', "select outline report format") do |type|
          self.format = :outline
        end
        opt.on('--format', '-f [TYPE]', "select report format") do |type|
          self.format = type
        end
        opt.on("-r [FILES]" , 'library files to require') do |files|
          files = files.split(/[:;]/)
          requires(*files)
        end
        opt.on("-I [PATH]" , 'include in $LOAD_PATH') do |path|
          paths = path.split(/[:;]/)
          includes(*paths)
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

    # Run unit tests.
    def run
      parser.parse!

      files = ARGV.dup

      includes.each do |path|
        $LOAD_PATH.unshift(path)
      end

      requires.each{ |path| require(path) }

      suite  = Lemon::Test::Suite.new(*files)
      runner = Lemon::Runner.new(suite, format, :cover=>coverage)
      runner.run
    end

  end

end
end

