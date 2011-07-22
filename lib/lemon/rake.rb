require 'rake/tasklib'

module Lemon

  module Rake

    # Define a lemon test rake task.
    #
    # The `TEST` environment variable can be used to select tests
    # when using the task.
    #
    # TODO: The test task uses #fork. Maybe it should shell out instead?
    class TestTask < ::Rake::TaskLib

      #
      DEFAULT_TESTS = [
        'test/**/case_*.rb',
        'test/**/*_case.rb',
        'test/**/test_*.rb',
        'test/**/*_test.rb'
      ]

      #
      attr_accessor :tests

      #
      attr_accessor :loadpath

      #
      attr_accessor :requires

      #
      attr_accessor :namespaces

      #
      attr_accessor :format

      #
      def initialize(name='lemon:test', desc="run lemon tests", &block)
        @name       = name
        @desc       = desc

        @loadpath   = ['lib']
        @requires   = []
        @tests      = [ENV['TEST']] || DEFAULT_TESTS
        @format     = nil
        @namespaces = []

        block.call(self)

        define_task
      end

      #
      def define_task
        desc @desc
        task @name do
          require 'open3'

          @tests ||= (
            if ENV['tests']
              ENV['tests'].split(/[:;]/)
            else
              DEFAULT_TESTS
            end
          )

          run
        end
      end

      #
      def run
        fork {
          #require 'lemon'
          require 'lemon/controller/test_runner'
          loadpath.each do |path|
            $LOAD_PATH.unshift(path)
          end
          requires.each do |file|
            require file
          end
          runner = Lemon::TestRunner.new(
            tests,
            :format => format,
            :namespaces => namespaces
          )
          success = runner.run
          exit -1 unless success
        }
        Process.wait
      end

      #
      #def ruby_command
      #  File.join(RbConfig::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
      #end

    end

  end

end
