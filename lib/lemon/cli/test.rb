module Lemon

  module CLI

    require 'lemon/cli/base'

    # Test Command
    class Test < Base

      # Run unit tests.
      def command_run(scripts)
        require 'lemon/runner'

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
        option_parser.banner = "Usage: lemonade test [options] [files ...]"
        #option_parser.separator("Run unit tests.")

        option_format
        option_verbose
        option_namespaces
        option_loadpath
        option_requires

        option_parser.parse!(argv)
      end

    end

  end

end
