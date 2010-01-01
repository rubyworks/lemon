require 'optparse'

#require 'lemon'
#require 'yaml'

module Lemon

  # Lemon Command-line tool base class.
  class Command

    # Used to map command-line options to command classes.
    # This must be overridden in subclasses, and return an
    # array of of options, e.g. [ '-g', '--generate'].
    def self.options
      raise "not implemented"
    end

    # Stores a list of command classes.
    def self.commands
      @commands ||= []
    end

    # When this class is inherited, it is registered to the commands list.
    def self.inherited(command_class)
      commands << command_class
    end

    # Factory method to initialize and run choosen sub-command.
    def self.run
      cmd = commands.find do |command_class|
        [command_class.options].flatten.find do |opt|
          ARGV.delete(opt)
        end
      end
      cmd ? cmd.run : Commands::Test.run
    end

  end

end

require 'lemon/commands/test'
require 'lemon/commands/coverage'
require 'lemon/commands/generate'

