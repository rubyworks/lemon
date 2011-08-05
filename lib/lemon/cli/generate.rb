module Lemon

  module CLI

    require 'lemon/cli/base'

    # Generate Command
    class Generate < Base

      # Generate test templates.
      def command_run(test_files)
        require 'lemon/generator'

        loadpath = options[:loadpath] || []
        requires = options[:requires] || []

        loadpath.each{ |path| $LOAD_PATH.unshift(path) }
        requires.each{ |path| require(path) }

        #cover = options[:uncovered]
        #suite = Lemon::TestSuite.new(test_files, :cover=>cover) #, :cover_all=>true)
        generator = Lemon::Generator.new(test_files, options)

        #if uncovered
        #  puts cover.generate_uncovered #(output)
        #else
          puts generator.generate #(output)
        #end
      end

      #
      def command_parse(argv)
        option_parser.banner = "Usage: lemonade generate [options] [files ...]"
        #option_parser.separator("Generate test scaffolding.")

        option_namespaces
        option_covered
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
