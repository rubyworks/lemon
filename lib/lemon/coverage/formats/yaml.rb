require 'lemon/coverage/formats/abstract'

module Lemon::CoverReports

  class Yaml < Abstract

    #
    def render
      puts checklist.to_yaml
    end

  end

end

