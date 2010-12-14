module Lemon

  # Access to metadata.
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/lemon.yml'))
    )
  end

  # Access to project metadata as constants.
  def self.const_missing(name)
    key = name.to_s.downcase
    metadata[key] || super(name)
  end

end

require 'lemon/controller/coverage_analyzer'
