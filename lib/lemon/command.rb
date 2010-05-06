require 'lemon/command/test'
require 'lemon/command/coverage'
require 'lemon/command/generate'

module Lemon
module Command

  # Factory method to initialize and run choosen sub-command.
  def self.run
    cmd = Abstract.commands.find do |command_class|
      /^#{ARGV.first}/ =~ command_class.subcommand
      #[command_class.options].flatten.find do |subcmd|
      #  #ARGV.delete(opt)
      #  /^#{ARGV.first}/ =~ subcmd
      #end
    end
    ARGV.shift if cmd
    cmd ? cmd.run : Command::Test.run
  end

end
end
