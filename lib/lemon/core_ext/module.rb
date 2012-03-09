class Module

  #
  def namespace
    i = name.rindex('::')
    i ? name[0...i] : name
  end

end
