module Lemon
module Test
module Reporter

  require 'lemon/test/reporter/dotprogress'
  require 'lemon/test/reporter/outline'
  require 'lemon/test/reporter/verbose'
  require 'lemon/test/reporter/timed'
  require 'lemon/test/reporter/tap'

  # TODO: make Reporter#factory more dynamic
  def self.factory(format, runner)
    format = format.to_s if format
    case format
    when 'v', 'verb', 'verbose'
      Reporter::Verbose.new(runner)
    when 'o', 'out', 'outline'
      Reporter::Outline.new(runner)
    when 't', 'time', 'time'
      Reporter::Timed.new(runner)
    when 'tap'
      Reporter::Tap.new(runner)
    else
      Reporter::DotProgress.new(runner)
    end
  end

end
end
end

