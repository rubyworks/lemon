Object.__send__(:remove_const, :VERSION) if Object.const_defined?(:VERSION)      # becuase Ruby 1.8~ gets in the way

module Uncool

  def self.__DIR__
    File.dirname(__FILE__)
  end

  def self.gemfile
    @gemfile ||= (
      require 'yaml'
      YAML.load(File.new(__DIR__ + '/gemfile.yml'))
    )
  end

  def self.profile
    @profile ||= (
      require 'yaml'
      YAML.load(File.new(__DIR__ + '/profile.yml'))
    )
  end

  def self.const_missing(name)
    name = name.to_s.downcase
    gemfile[name] || profile[name]
  end

end

