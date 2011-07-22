module Lemon

  require 'optparse'

  # TODO: What about a config file?

  # CLI Interfaces handle all lemon sub-commands.
  module CLI

    # Rin command.
    def self.run(command, argv=ARGV)
      klass = const_get(command.to_s.capitalize)
      klass.new.run(argv)
    end

    # Base class for all commands.
    class Base

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
        begin
          command_parse(argv)
          command_run(argv)
        rescue => err
          raise err if $DEBUG
          $stderr.puts('ERROR: ' + err.to_s)
        end
      end

      #
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

      #
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

    end

    # Test Command
    class Test < Base

      # Run unit tests.
      def command_run(scripts)
        require 'lemon/controller/test_runner'

        loadpath = options[:loadpath] || ['lib']  # + ['lib'] ?
        requires = options[:requires] || []

        loadpath.each{ |path| $LOAD_PATH.unshift(path) }
        requires.each{ |path| require(path) }

        #suite  = Lemon::Test::Suite.new(files, :cover=>cover)
        #runner = Lemon::Runner.new(suite, :format=>format, :cover=>cover, :namespaces=>namespaces)

        runner = Lemon::TestRunner.new(
          scripts, :format=>options[:format], :namespaces=>options[:namespaces]
        )

        success = runner.run

        exit -1 unless success
      end

      #
      def command_parse(argv)
        option_parser.banner = "Usage: lemon [-t] [options] [files ...]"
        #option_parser.separator("Run unit tests.")

        option_format
        option_verbose
        option_namespaces
        option_loadpath
        option_requires

        option_parser.parse!(argv)
      end

    end

    # Coverage Command
    class Coverage < Base

      # Ouput coverage report.
      def command_run(test_files)
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
      def command_parse(argv)
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

    end

    # Generate Command
    class Generate < Base

      # Generate test templates.
      def command_run(test_files)
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
      def command_parse(argv)
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

    end

  end

end
