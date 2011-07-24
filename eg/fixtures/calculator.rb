class Calculator

  def initialize
    @stack = []
  end

  def push(int)
    @stack << int
  end
  
  def add
    @stack.inject(0){ |sum, val| sum += val; sum }
  end

end
