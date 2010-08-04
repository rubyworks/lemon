#require 'lemon/coverage'

module Lemon
  DIRECTORY = File.dirname(__FILE__)

  def self.gemfile
    @gemfile ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/lemon.meta/gemfile'))
    )
  end

  def self.profile
    @profile ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/lemon.meta/profile'))
    )
  end

  def self.const_missing(name)
    name = name.to_s.downcase
    gemfile[name] || profile[name]
  end

  require 'lemon/rind/app'

  # Run coverage trace and log results.
  #
  #  targets = ENV['squeeze'].split(',')
  #  Lemon.log(targets, :output=>'log')
  #
  # NOTE: This sets up an at_exit routine.
  def self.log(namespaces, options={})
    app = App.new(namespaces, options={})
    app.log
  end

end

