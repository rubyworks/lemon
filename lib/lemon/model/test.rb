require 'lemon/model/test_suite'

module Test
  extend self

  #
  def covers(script)
    Lemon.suite.dsl.covers(script)
  end
  alias :Covers :covers

  alias :coverage :covers
  alias :Coverage :covers

  # Define a general test case.
  def case(target, &block)
    Lemon.suite.dsl.test_case(target, &block)
  end
  alias :Case :case

  # Define a class test.
  def class(target_class, &block)
    Lemon.suite.dsl.test_class(target_class, &block)
  end
  alias :Class :class

  # Define a module test.
  def module(target_module, &block)
    Lemon.suite.dsl.test_module(target_module, &block)
  end
  alias :Module :module

  # Define a test feature.
  def feature(target, &block)
    Lemon.suite.dsl.test_feature(target, &block)
  end
  alias :Feature :feature

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
