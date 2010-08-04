require 'ae'

module Lemon

  def self.suite
    @suite ||= Suite.new(Runner.new(Reporter.new))
  end

  def self.suite=(suite)
    @suite = suite
  end

  class Context
    def initialize(desc=nil)
      @desc   = desc
      @before = {}
      @after  = {}
    end

    def description
      @desc
    end

    def before(which, &block)
      @before[which] = block if block
      @before[which]
    end

    def after(which, &block)
      @after[which] = block if block
      @after[which]
    end
  end

  class Suite
    def initialize(runner)
      @runner = runner
    end

    def before(which, &block)
      @runner.before(which, &block)
    end

    def after(which, &block)
      @runner.after(which, &block)
    end

    def unit(mod, meth, desc=nil, &block)
      @runner.unit(mod, meth, desc, &block)
    end

    def context(desc, &block)
      @runner.context(desc, &block)
    end
  end

  # Runner is a listner.
  class Runner
    #
    def initialize(*reporters)
      @reporters = reporters
      #@before = {} #Hash.new{|h,k| h[k]=[]}
      #@after  = {} #Hash.new{|h,k| h[k]=[]}
      @context_stack = [Context.new]
    end

    def before(which, &block)
      @context_stack.last.before(which, &block)
      @reporters.each do |reporter|
        reporter.before(which, &block)
      end
    end

    def after(which, &block)
      @context_stack.last.after(which, &block)
      @reporters.each do |reporter|
        reporter.after(which, &block)
      end
    end

    def instance(desc, &block)
      @instance = Context.new(desc, &block)
    end

    def unit(mod, meth, desc=nil, &block)
      @reporters.each do |reporter|
        reporter.unit(mod, meth, desc, &block)
      end

      if @instance && block.arity != 0
        block.call(@instance.call)
      else
        block.call
      end

    end
  end

  class Reporter
    #
    def initialize
    end

    def before(which, &block)
    end

    def after(which, &block)
    end

    def unit(mod, meth, desc=nil, &block)
      puts "%s#%s %s" % [mod.name, meth.to_s, desc]
    end
  end

end


#
def before(which, &block)
  Lemon.suite.before(which, &block)
end

#
def after(which, &block)
  Lemon.suite.after(which, &block)
end

#
def unit(mod, meth, desc=nil, &blk)
  Lemon.suite.unit(mod, meth, desc, &blk)
end

def context(desc, &block)
  Lemon.suite.context(desc, &block)
end

