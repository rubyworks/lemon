module Lemon

  require 'optparse'

  module CLI

    # Base class for all commands.
    class Base

      #
      def self.run(argv)
        new.run(argv)
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
        #rescue => err
        #  raise err if $DEBUG
        #  $stderr.puts('ERROR: ' + err.to_s)
        end
      end

    private

      #
      # Initialize new command instance. This will be overriden in subclasses.
      #
      def initialize(argv=ARGV)
        @options = {}
      end

      #
      # Parse command line argument. This is a no-op as it will be overridden
      # in subclasses.
      #
      def command_parse(argv)
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

      # -n --namespace
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

      # -f --format
      def option_format
        option_parser.on('-f', '--format NAME', 'output format') do |name|
          options[:format] = name
        end
      end

      # -v --verbose
      def option_verbose
        option_parser.on('-v', '--verbose', 'shortcut for `-f verbose`') do |name|
          options[:format] = 'verbose'
        end
      end

      # -c --covered, -u --uncovered and -a --all
      def option_coverage
        option_parser.on('-c', '--covered', 'include covered units') do
         if options[:coverage] == :uncovered
            options[:coverage] = :all
         else 
           options[:coverage] = :covered
         end
        end
        option_parser.on('-u', '--uncovered', 'include only uncovered units') do
          if options[:coverage] == :covered
            options[:coverage] = :all
          else
            options[:coverage] = :uncovered
          end
        end
        option_parser.on('-a', '--all', 'include all namespaces and units') do
          options[:coverage] = :all
        end
      end

      # -p --private
      def option_private
        option_parser.on('-p', '--private', 'include private and protected methods') do
          options[:private] = true
        end
      end

      # -z --zealous
      def option_zealous
        option_parser.on('-z', '--zealous', 'include undefined case methods') do
          options[:zealous] = true
        end
      end

      # -o --output
      def option_output
        option_parser.on('-o', '--output DIRECTORY', 'output directory') do |dir|
          options[:output] = dir
        end
      end

      # -I
      def option_loadpath
        option_parser.on("-I PATH" , 'add directory to $LOAD_PATH') do |path|
          paths = path.split(/[:;]/)
          options[:loadpath] ||= []
          options[:loadpath].concat(paths)
        end
      end

      # -r
      def option_requires
       option_parser.on("-r FILE" , 'require file(s) (before doing anything else)') do |files|
          files = files.split(/[:;]/)
          options[:requires] ||= []
          options[:requires].concat(files)
        end
      end

      # --dryrun
      def option_dryrun
        option_parser.on('--dryrun', 'no disk writes') do
          options[:dryrun] = true
        end
      end

    end

  end

end
