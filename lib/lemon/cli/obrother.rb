module Lemon

  module CLI

    require 'lemon/cli/base'

    # The ol' "Sing it, Brother" Command.
    #
    class OBrother < Base

      #
      def command_run(argv)
        if argv.any?{ |a| a.downcase == 'good' }
          show_ascii_art
        else
          puts "No, they are GOOD!"
        end
      end

      #
      def show_ascii_art
        string = File.read(File.dirname(__FILE__) + '/lemon.ascii')
        begin
          require 'ansi'
          puts string.ansi(:yellow)
        rescue LoadError
          puts string
        end
      end

    end

  end

end
