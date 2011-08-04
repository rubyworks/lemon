require 'lemon/view/cover_reports/abstract'

module Lemon::CoverReports

  class Yaml < Abstract

    #
    def render
      puts checklist.to_yaml
    end

  end

end

