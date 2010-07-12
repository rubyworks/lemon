# Current suite being defined. This is used
# to define a Suite object via the toplevel DSL.
def Lemon.suite
  @suite
end

#
def Lemon.suite=(suite)
  @suite = suite
end

#
def Before(match=nil, &block)
  Lemon.suite.Before(match, &block)
end

#
def After(match=nil, &block)
  Lemon.suite.After(match, &block)
end

#
def When(match=nil, &block)
  Lemon.suite.When(match, &block)
end

#
def Case(target_class, &block)
  Lemon.suite.Case(target_class, &block)
end
alias :TestCase :Case

#
def Covers(script)
  Lemon.suite.Covers(script)
end

#
def Helper(script)
  Lemon.suite.Helper(script)
end

#def Subtest(script)
#  Lemon.suite.Subtest(script)
#end

# FIXME: This is a BIG FAT HACK! For the life of me I cannot find
# a way to resolve module constants included in the test cases.
# Because of closure, the constant lookup goes through here, and not
# the Case singleton class. So to work around we must note each test
# before it is run, and reroute the missing constants.
#
# This sucks and it is not thread safe. If anyone know how to fix,
# please let me know. See Unit#call for the other end of this hack.

def Object.const_missing(name)
  if unit = Lemon.test_stack.last
    klass = (class << unit.testcase; self; end)
    if klass.const_defined?(name)
      return klass.const_get(name)
    end
  end
  super(name)
end

# Get current running test. Used for the BIG FAT HACK.
def Lemon.test_stack
  @@test_stack ||= []
end

