module Lemon

  require 'optparse'

  # TODO: What about a config file?

  # CLI Interface handle all lemon sub-commands.
  class CLI

    COMMANDS = {
      '-t' => 'test'    , '--test' => 'test',
      '-c' => 'coverage', '--cov'  => 'coverage', '--coverage' => 'coverage',
      '-g' => 'generate', '--gen'  => 'generate', '--generate' => 'generate' 
    }

    #
    def self.run(argv=ARGV)
      new.run(argv)
    end

    #
    def initialize(argv=ARGV)
      @options = {}
    end

    #
    def options
      @options
    end

    #
    def run(argv)
      cmdopt  = COMMANDS.keys.find{ |k| argv.delete(k)  }
      command = COMMANDS[cmdopt]

      if command.nil? && argv.include?('--help')
        option_commands
        option_parser.parse!(argv)
      end

      command ||= 'test'

      #option_commands

      #cmd = argv.shift
      #cmd = COMMANDS.find{ |c| /^#{cmd}/ =~ c }
      #option_parser.order!(argv)

      begin
        __send__("#{command}_parse", argv)
        __send__("#{command}", argv)
      rescue => err
        raise err if $DEBUG
        $stderr.puts('ERROR: ' + err.to_s)
      end
    end

    # T E S T

    # Run unit tests.
    def test(scripts)
      require 'lemon/controller/test_runner'

      loadpath = options[:loadpath] || []
      requires = options[:requires] || []

      loadpath.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      #suite  = Lemon::Test::Suite.new(files, :cover=>cover)
      #runner = Lemon::Runner.new(suite, :format=>format, :cover=>cover, :namespaces=>namespaces)

      runner = Lemon::TestRunner.new(
        scripts, :format=>options[:format], :namespaces=>options[:namespaces]
      )

      runner.run
    end

    #
    def test_parse(argv)
      option_parser.banner = "Usage: lemon [-t] [options] [files ...]"
      #option_parser.separator("Run unit tests.")

      option_format
      option_verbose
      option_namespaces
      option_loadpath
      option_requires

      option_parser.parse!(argv)
    end

    # C O V E R A G E

    # Ouput coverage report.
    def coverage(test_files)
      require 'lemon/controller/coverage_analyzer'

      #loadpath = options[:loadpath] || []
      #requires = options[:requires] || []

      #loadpath.each{ |path| $LOAD_PATH.unshift(path) }
      #requires.each{ |path| require(path) }

      $stderr.print "Calculating... "
      $stderr.flush

      cover = Lemon::CoverageAnalyzer.new(test_files, options)

      cover.calculate  # this just helps calcs get done up front

      $stderr.puts

      cover.render
    end

    #
    def coverage_parse(argv)
      option_parser.banner = "Usage: lemon -c [options] [files ...]"
      #option_parser.separator("Check test coverage.")

      option_namespaces
      option_private
      option_zealous
      option_output
      option_format
      option_loadpath
      option_requires

      option_parser.parse!(argv)
    end

    # G E N E R A T E

    # Generate test templates.
    def generate(test_files)
      require 'lemon/controller/scaffold_generator'

      loadpath = options[:loadpath] || []
      requires = options[:requires] || []

      loadpath.each{ |path| $LOAD_PATH.unshift(path) }
      requires.each{ |path| require(path) }

      #cover = options[:uncovered]
      #suite = Lemon::TestSuite.new(test_files, :cover=>cover) #, :cover_all=>true)
      generator = Lemon::ScaffoldGenerator.new(test_files, options)

      #if uncovered
      #  puts cover.generate_uncovered #(output)
      #else
        puts generator.generate #(output)
      #end
    end

    #
    def generate_parse(argv)
      option_parser.banner = "Usage: lemon -g [options] [files ...]"
      #option_parser.separator("Generate test scaffolding.")

      option_namespaces
      option_uncovered
      option_all
      option_private
      option_loadpath
      option_requires

      option_parser.parse!(argv)
    end

    # P A R S E R  O P T I O N S

    def option_commands
      option_parser.banner = "Usage: lemon [command] [options] [files ...]"
      option_parser.on('-t', '--test', 'run unit tests [default]') do
        @command = :test
      end
      option_parser.on('-c', '--cov', '--coverage', 'provide test coverage analysis') do
        @command = :coverage
      end
      option_parser.on('-g', '--gen', '--generate', 'generate unit test scaffolding') do
        @command = :generate
      end
    end

    def option_namespaces
      option_parser.on('-n', '--namespace NAME', 'add a namespace to output') do |name|
        options[:namespaces] ||= []
        options[:namespaces] << name
      end
    end

    #def option_framework
    #  option_parser.on('-f', '--framework NAME', 'framework syntax to output') do |name|
    #    options[:framework] = name.to_sym
    #  end
    #end

    def option_format
      option_parser.on('-f', '--format NAME', 'output format') do |name|
        options[:format] = name
      end
    end

    def option_verbose
      option_parser.on('-v', '--verbose', 'shortcut for `-f verbose`') do |name|
        options[:format] = 'verbose'
      end
    end

    def option_uncovered
      option_parser.on('-u', '--uncovered', 'include only uncovered units') do
        options[:uncovered] = true
      end
    end

    def option_all
      option_parser.on('-a', '--all', 'include all namespaces and units') do
        options[:all] = true
      end
    end

    def option_private
      option_parser.on('-p', '--private', 'include private and protected methods') do
        options[:private] = true
      end
    end

    def option_zealous
      option_parser.on('-z', '--zealous', 'include undefined case methods') do
        options[:zealous] = true
      end
    end

    def option_output
      option_parser.on('-o', '--output DIRECTORY', 'log directory') do |dir|
        options[:output] = dir
      end
    end

    def option_loadpath
      option_parser.on("-I PATH" , 'add directory to $LOAD_PATH') do |path|
        paths = path.split(/[:;]/)
        options[:loadpath] ||= []
        options[:loadpath].concat(paths)
      end
    end

    def option_requires
     option_parser.on("-r FILE" , 'require file(s) (before doing anything else)') do |files|
        files = files.split(/[:;]/)
        options[:requires] ||= []
        options[:requires].concat(files)
      end
    end

    def option_parser
      @option_parser ||= (
        OptionParser.new do |opt|
          opt.on_tail("--[no-]ansi" , 'turn on/off ANIS colors') do |v|
            $ansi = v
          end
          opt.on_tail("--debug" , 'turn on debugging mode') do
            $DEBUG = true
          end
          opt.on_tail("--about" , 'display information about lemon') do
            puts "Lemon v#{Lemon::VERSION}"
            puts "#{Lemon::COPYRIGHT}"
            exit
          end
          opt.on_tail('-h', '--help', 'display help (also try `<command> --help`)') do
            puts opt
            exit
          end
        end
      )
    end

  end

end

