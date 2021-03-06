# NOTE: This code is not being used. It is here for the time being
# on the outseide change that I decide to go back to a toplevel design.

require 'lemon/model/test_suite'

class << self

  #
  def Covers(script)
    Lemon.suite.dsl.covers(script)
  end
  alias :Coverage :Covers

  # Define a general test case.
  def Case(target, &block)
    Lemon.suite.dsl.test_case(target, &block)
  end

  # Define a class test.
  def Class(target_class, &block)
    Lemon.suite.dsl.test_class(target_class, &block)
  end

  # Define a module test.
  def Module(target_module, &block)
    Lemon.suite.dsl.test_module(target_module, &block)
  end

  # Define a test feature.
  def Feature(target, &block)
    Lemon.suite.dsl.test_feature(target, &block)
  end

  #
  #def Before(match=nil, &block)
  #  Lemon.suite.Before(match, &block)
  #end

  #
  #def After(match=nil, &block)
  #  Lemon.suite.After(match, &block)
  #end

  #
  #def Helper(script)
  #  Lemon.suite.Helper(script)
  #end
end

=begin
# FIXME: This is a BIG FAT HACK! For the life of me I cannot find
# a way to resolve module constants included in the test cases.
# Because of closure, the constant lookup goes through here, and not
# the Case singleton class. So to work around we must note each test
# before it is run, and reroute the missing constants.
#
# This sucks and it is not thread safe. If anyone know how to fix,
# please let me know. See Unit#call for the other end of this hack.
#
def Object.const_missing(name)
  if unit = Lemon.test_stack.last
    begin
      (class << unit.test_case; self; end).const_get(name)
    rescue NameError
      super(name)
    end
  else
    super(name)
  end
end

#def Object.const_missing(name)
#  if unit = Lemon.test_stack.last
#    klass = (class << unit.test_case; self; end)
#    if klass.const_defined?(name)
#      return klass.const_get(name)
#    end
#  end
#  super(name)
#end

# Get current running test. Used for the BIG FAT HACK.
def Lemon.test_stack
  @@test_stack ||= []
end
=end

