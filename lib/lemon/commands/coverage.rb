module Lemon
module Commands

  # Lemon Coverage Command-line tool.
  class Coverage < Command
    require 'yaml'
    require 'lemon/coverage'

    def self.options
      ['-c', '--coverage']
    end

    # Initialize and run.
    def self.run
      new.run
    end

    # New Command instance.
    def initialize
      @requires    = []
      @includes    = []
      @namespaces  = []
      @public_only = false
    end

    #
    attr_accessor :public_only

    #
    def public_only?
      @public_only
    end

    # Get or set librarires to pre-require.
    def requires(*paths)
      @requires.concat(paths) unless paths.empty?
      @requires
    end

    # Get or set paths to include in $LOAD_PATH.
    def includes(*paths)
      @includes.concat(paths) unless paths.empty?
      @includes
    end

    # Get or set paths to include in $LOAD_PATH.
    def namespaces(*names)
      @namespaces.concat(names) unless names.empty?
      @namespaces
    end

    # Instance of OptionParser.
    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "lemon -c [OPTIONS]"
        opt.separator("Produce test coverage reports.")
        opt.on('--namespace', '-n [NAME]', "include namespace") do |name|
          namespaces(name)
        end
        opt.on('--public', '-p', "only include public methods") do
          self.public_only = true
        end
        opt.on("-r [FILES]" , 'library files to require') do |files|
          files = files.split(/[:;]/)
          requires(*files)
        end
        opt.on("-I [PATH]" , 'include in $LOAD_PATH') do |path|
          path = path.split(/[:;]/)
          includes(*path)
        end
        opt.on("--debug" , 'turn on debugging mode') do
          $DEBUG = true
        end
        opt.on_tail('--help', '-h', 'show this help message') do
          puts opt
          exit
        end
      end
    end

    #
    def run
      parser.parse!

      includes.each do |path|
        $LOAD_PATHS.unshift(path)
      end

      files = ARGV.dup

      cover  = Lemon::Coverage.new(requires, namespaces, :public => public_only?)
      suite  = Lemon::Test::Suite.new(tests)
      puts cover.coverage(suite).to_yaml
    end

  end

end
end

