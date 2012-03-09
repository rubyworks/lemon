#require 'lemon/cli/runner'
require 'lemon/cli/generate'
require 'lemon/cli/scaffold'
require 'lemon/cli/coverage'
require 'lemon/cli/obrother'

module Lemon

  # CLI Interfaces handle all lemon sub-commands.
  #
  module CLI
  end

  #--
  # TODO: Use Lemon::CLI::Runner and have it delegate to RubyTest ?
  #++

  # Command line interface takes the first argument off `argv` to determine
  # the subcommand: `test`, `cov` or `gen`. If `test`, then Lemon delegates
  # control to Ruby Test.
  #
  def self.cli(*argv)
    cmd = argv.shift
    case cmd
    when 't', 'test', 'run'
      require 'lemon'
      require 'rubytest'
      Test::Runner.cli(*ARGV)
      #Lemon::CLI::Test.new.run(argv)
    when 'g', 'gen', 'generate', 'generator'
      Lemon::CLI::Generate.run(argv)
    when 's', 'sca', 'scaffold'
      Lemon::CLI::Scaffold.run(argv)
    when 'c', 'cov', 'cover', 'coverage'
      Lemon::CLI::Coverage.run(argv)
    when 'are'
      Lemon::CLI::OBrother.run(argv)
    else
      # run tests instead?
      puts "invalid lemon command -- #{cmd}"
      exit -1
    end
  end

end
