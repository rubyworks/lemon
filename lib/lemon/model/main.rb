# NOTE: This code is not being used. It is here for the time being
# on the outseide change that I decide to go back to a toplevel design.

require 'lemon/model/test_suite'

#
#def Before(match=nil, &block)
#  Lemon.suite.Before(match, &block)
#end

#
#def After(match=nil, &block)
#  Lemon.suite.After(match, &block)
#end

#
def testcase(target_class, &block)
  Lemon.suite.dsl.testcase(target_class, &block)
end
alias :TestCase :testcase
alias :Case :testcase
alias :tests :testcase # can't use test b/c of kernel method

#
def covers(script)
  Lemon.suite.dsl.covers(script)
end
alias :Covers :covers

#
#def Helper(script)
#  Lemon.suite.Helper(script)
#end

#def Subtest(script)
#  Lemon.suite.Subtest(script)
#end

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
      (class << unit.testcase; self; end).const_get(name)
    rescue NameError
      super(name)
    end
  else
    super(name)
  end
end

#def Object.const_missing(name)
#  if unit = Lemon.test_stack.last
#    klass = (class << unit.testcase; self; end)
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

