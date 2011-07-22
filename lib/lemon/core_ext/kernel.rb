module Kernel

  unless method_defined?(:qua_class)

    def qua_class(&block)
      if block_given?
        (class << self; self; end).class_eval(&block)
      else
        (class << self; self; end)
      end
    end

    alias :quaclass :qua_class
  end

  unless method_defined?(:singleton_class)
    alias :singleton_class :quaclass
  end

end
