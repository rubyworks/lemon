module Lemon

  module CLI

    require 'lemon/cli/base'

    # Generate Command
    #
    class Generate < Base

      # Generate test templates.
      def command_run(files)
        if i = files.index('-')
          options[:files] = files[0...i]
          options[:tests] = files[i+1..-1]
        else
          options[:files] = files
          options[:tests] = []
        end

        require 'lemon/generator'

        loadpath = options[:loadpath] || []
        requires = options[:requires] || []

        loadpath.each{ |path| $LOAD_PATH.unshift(path) }
        requires.each{ |path| require(path) }

        generator = Lemon::Generator.new(options)

        render_map = generator.generate

        generate_output(render_map)
      end

      #
      def generate_output(render_map)
        render_map.each do |group, test|
          puts "# --- #{group} ---"
          puts
          puts test
        end
      end

      #
      def command_parse(argv)
        option_parser.banner = "Usage: lemons generate [options] [files ...]"

        setup_options

        option_parser.parse!(argv)
      end

      #
      def setup_options
        option_group
        option_namespaces
        option_private
        option_caps
        option_loadpath
        option_requires
      end

      # -f --file
      def option_group
        option_parser.on('-f', '--file', 'group tests by file') do
          options[:group] = :file
        end
        #option_parser.on('-c', '--case', 'group tests by case') do
        #  options[:group] = :case
        #end
      end

      # -C --caps
      def option_caps
        option_parser.on('-C', '--caps', 'use capitalized test terms') do
          options[:caps] = true
        end
      end

    end

  end

end
