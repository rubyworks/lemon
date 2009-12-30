  #
  module M
    def m1; "m1"; end
    module N
      def self.n1; "n1"; end
    end
  end

  class X
    class << self
      alias _new new
      def new(&block)
        klass = Class.new(self)
        klass.module_eval(&block)
        klass._new
      end
    end

    def m ; m1 ; end
    def n ; N.n1 ; end
  end

  x = X.new do
    include M
  end

  p x.m
  p x.n


exit

class X
  attr :set
  def initialize(&block)
    @set = {}
    instance_eval(&block)
  end
  def defset(name, &block)
    @set[name] = block
  end
  def include(*mods)
    (class << self; self; end).class_eval do
      include *mods
    end
  end
end

#
module M
  def m1; "m1"; end
  module N
    def self.n1; "n1"; end
  end
end

x = X.new do

  include M

  #Before /returns/ do |unit|
  #  puts "returns something"
  #end

  defset :m do
    m1 == "m1"
  end

  defset :n do
    N.n1 == "n1"
  end

end

x.set[:m].call
x.set[:n].call
