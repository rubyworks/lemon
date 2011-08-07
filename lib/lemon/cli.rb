#require 'lemon/cli/test'
require 'lemon/cli/generate'
require 'lemon/cli/coverage'

module Lemon

  # Run command.
  def self.cli(*argv)
    cmd = argv.shift
    case cmd
    when 'test'
      require 'lemon'
      require 'test/cli'
      Test::Runner.cli(*ARGV)
      #Lemon::CLI::Test.new.run(argv)
    when /^gen/
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
