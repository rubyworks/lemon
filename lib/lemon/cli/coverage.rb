module Lemon

  module CLI

    require 'lemon/cli/base'

    # Coverage Command
    class Coverage < Base

      # Ouput coverage report.
      def command_run(test_files)
        require 'lemon/coverage/analyzer'

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
        option_parser.banner = "Usage: lemonade coverage [options] [files ...]"
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

  end

end
