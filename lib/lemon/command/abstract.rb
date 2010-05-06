module Lemon
module Command
  require 'optparse'

  # Lemon Command-line tool base class.
  class Abstract

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

  end

end
end

