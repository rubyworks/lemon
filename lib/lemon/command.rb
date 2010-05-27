module Lemon
  require 'lemon'

  # Lemon Command-line tool.
  class Command

    # Initialize and run.
    def self.run
      new.run
    end

    # New Command instance.
    def initialize
      @command     = :test
      @format      = nil
      @requires    = []
      @includes    = []
      @namespaces  = []
      @uncovered   = false
      @public_only = false
    end

    #
    attr_accessor :command

    #
    attr_accessor :format

    #
    attr_accessor :requires

    #
    attr_accessor :includes

    #
    attr_accessor :namespaces

    #
    attr_accessor :uncovered

    #
    attr_accessor :public_only


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
        opt.banner = "lemon [options] [files ...]"
        opt.separator("Run unit tests.")
        opt.separator("COMMAND OPTIONS (choose one):")
        opt.on('--test', '-t', "run unit tests [default]") do
          self.command = :test
        end
        opt.on('--coverage', '-c', "provide test coverage analysis") do
          self.command = :cover
        end
        opt.on('--generate', '-g', "generate unit test scaffolding") do
          self.command = :generate
        end
        opt.separator("COMMON OPTIONS:")
        opt.on('--verbose', '-v', "select verbose report format") do |type|
          self.format = :verbose
        end
        opt.on('--outline', '-o', "select outline report format") do |type|
          self.format = :outline
        end
        opt.on('--format', '-f [TYPE]', "select report format") do |type|
          self.format = type
        end
        opt.on("--namespace", "-n [NAME]", "limit testing to this namespace") do |name|
          namespaces(name)
        end
        opt.separator("GENERATOR OPTIONS:")
        opt.on("--uncovered", "-u", "only include uncovered methods") do
          self.uncovered = true
        end
        opt.separator("COVERAGE & GENERATOR OPTIONS:")
        opt.on('--public', '-p', "only include public methods") do
          self.public_only = true
        end
        opt.separator("RUNTIME OPTIONS:")
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

    # Run command.
    def run
      parser.parse!
      __send__(@command)
    end

    # Run unit tests.
    def test
      require 'lemon/runner'

      files = ARGV.dup

      includes.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      #suite  = Lemon::Test::Suite.new(files, :cover=>cover)
      #runner = Lemon::Runner.new(suite, :format=>format, :cover=>cover, :namespaces=>namespaces)

      suite  = Lemon::Test::Suite.new(files)
      runner = Lemon::Runner.new(suite, :format=>format, :namespaces=>namespaces)

      runner.run
    end

    # Ouput coverage report.
    def cover
      test_files = ARGV.dup
      load_files = []

      includes.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      suite    = Lemon::Test::Suite.new(test_files, :cover=>true)
      coverage = Lemon::Coverage.new(suite, namespaces, :public=>public_only)

      coverage.format(format)
    end

    # Generate test templates.
    def generate
      test_files = ARGV.dup

      includes.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      suite = Lemon::Test::Suite.new(test_files, :cover=>true)
      cover = Lemon::Coverage.new(suite, namespaces, :public=>public_only)
      #cover  = Lemon::Coverage.new([], namespaces, :public=>public_only?, :uncovered=>uncovered)

      if uncovered
        puts cover.generate_uncovered #(output)
      else
        puts cover.generate #(output)
      end

    end

  end

end

