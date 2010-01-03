def Lemon.suite
  @suite
end

def Lemon.suite=(suite)
  @suite = suite
end


def Before(match=nil, &block)
  Lemon.suite.Before(match, &block)
end

def After(match=nil, &block)
  Lemon.suite.After(match, &block)
end

def When(match=nil, &block)
  Lemon.suite.When(match, &block)
end

def Case(target_class, &block)
  Lemon.suite.Case(target_class, &block)
end

alias :TestCase :Case

