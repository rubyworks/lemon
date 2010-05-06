require 'lemon/reporter/dotprogress'
require 'lemon/reporter/outline'
require 'lemon/reporter/verbose'

module Lemon
module Reporter

  # TODO: make Reporter#factory more dynamic
  def self.factory(format, runner)
    format = format.to_s if format
    case format
    when 'v', 'verb', 'verbose'
      Reporter::Verbose.new(runner)
    when 'o', 'out', 'outline'
      Reporter::Outline.new(runner)
    else
      Reporter::DotProgress.new(runner)
    end
  end

end
end
