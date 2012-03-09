module Lemon

  module CLI

    require 'lemon/cli/generate'
    require 'fileutils'

    # Scaffold Command
    class Scaffold < Generate

      # TODO: To be on the safe side, maybe require a --force option in order
      #       to write into a test directory that already has content.

      #
      # Unlike the Generate command, the Scaffold commnad writes output
      # to test files.
      #
      def generate_output(render_map)
        render_map.each do |group, test|
          file = test_file(group)

          if File.exist?(file)
            append_test(file, test)
          else
            write_test(file, test)
          end
        end
      end

      #
      #
      #
      def command_parse(argv)
        option_parser.banner = "Usage: lemons scaffold [options] [files ...]"
        setup_options
        option_parser.parse!(argv)
      end

      #
      #
      #
      def setup_options
        option_output
        option_dryrun
        super
      end

      #
      # Output directory, default is `test`.
      #
      def output
        options[:output] || 'test'
      end

      #
      #
      #
      def dryrun?
        options[:dryrun]
      end

      #
      # Given the group name, convert it to a suitable test file name.
      #
      def test_file(group)
        if options[:group] == :file
          file = group
        else
          file = group.gsub('::', '/').downcase
        end

        dirname, basename = File.split(file)

        if i = dirname.index('/')
          dirname = dirname[i+1..-1]
          file = File.join(dirname, output, "case_#{basename}")
        else
          file = File.join(output, "case_#{basename}")
        end
      end

      #
      # Write test file.
      #
      def write_test(file, test)
        return if test.strip.empty?
        if dryrun?
          puts "[DRYRUN] write #{file}"
        else
          dir = File.dirname(file)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
          File.open(file, 'w'){ |f| f << test.to_s }
          puts "write #{file}"
        end       
      end

      #
      # Append tests to file.
      #
      def append_test(file, test)
        return if test.strip.empty?
        if dryrun?
          puts "[DRYRUN] append #{file}"
        else
          dir = File.dirname(file)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
          File.open(file, 'a'){ |f| f << "\n" + test.to_s }
          puts "append #{file}"
        end
      end

    end

  end

end
