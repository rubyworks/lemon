module Lemon
module Rind

  require 'lemon/rind/trace'

  #
  class App

    #
    def initialize(targets, options={})
      @targets = targets
      @options = options
    end

    #
    attr :targets

    #
    attr :options

    #
    def trace
      @trace ||= Trace.new(targets, options)
    end

    #
    def analysis
      @analysis ||= Analysis.new(trace, options)
    end

    #
    def report
      @report ||= Report.new(analysis, options)
    end

    # This is the main method for activating hte trace and
    # recording the results.
    def log(logdir=nil)
      logdir = logdir || options[:output]
      trace.setup
      at_exit {
        trace.deactivate
        logdir ? report.save(logdir) : report.display
      }
      trace.activate
    end

    # CLI interface
    def self.cli(argv=ARGV)
      require 'optparse'

      namespaces = []
      logdir     = nil
      options    = {}

      parser = OptionParser.new do |opt|
        opt.on('--namespace', '-n NAMESPACE', 'namespace to include in analysis') do |ns|
          namespaces << ns
        end
        opt.on('--private', '-p', 'include private/protected methods') do
          options[:private] = true
        end
        opt.on('--log', '-o DIRECTORY', 'log directory') do |dir|
          options[:output] = dir
        end
        opt.on('--format', '-f NAME', 'output format') do |name|
          options[:format] = name
        end
        opt.on_tail('--help', '-h', 'display this help message') do
          puts opt
          exit 0
        end
      end

      parser.parse!(argv)

      app = App.new(namespaces, options)
      app.log(logdir)

      argv.each do |file|
        load(file)
      end
    end

  end

end
end

