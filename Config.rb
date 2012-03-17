#!/usr/bin/env ruby

profile :coverage do

  config :qed do
    require 'simplecov'
    SimpleCov.start do
      coverage_dir 'log/coverage'
      #add_group "Label", "lib/qed/directory"
    end
  end

end

