module Lemon

  #
  def self.ignore_callers
    ignore_path    = File.expand_path(File.join(__FILE__, '../../..'))
    ignore_regexp  = Regexp.new(Regexp.escape(ignore_path))
    [ ignore_regexp, /bin\/lemon/ ]
  end

  #
  def self.setup_ignore_callers
    $RUBY_IGNORE_CALLERS ||= []
    $RUBY_IGNORE_CALLERS.concat(ignore_callers)
  end

end

#
Lemon.setup_ignore_callers
