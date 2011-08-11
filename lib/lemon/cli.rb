#require 'lemon/cli/test'
require 'lemon/cli/generate'
require 'lemon/cli/coverage'

module Lemon

  #--
  # TODO: Use Lemon::CLI::Runner and have it delegate to Ruby Test ?
  #++

  # Command line interface takes the first argument off `argv` to determine
  # the subcommand: `test`, `cov` or `gen`. If `test`, then Lemon delegates
  # control to Ruby Test.
  #
  def self.cli(*argv)
    cmd = argv.shift
    case cmd
    when 'test'
      require 'lemon'
      require 'test/cli'
      Test::Runner.cli(*ARGV)
      #Lemon::CLI::Test.new.run(argv)
    when /^gen/, /^scaf/
      Lemon::CLI::Generate.new.run(argv)
    when /^cov/
      Lemon::CLI::Coverage.new.run(argv)
    else
      # run tests instead?
      puts "invalid lemon command -- #{cmd}"
      exit -1
    end
  end

end
