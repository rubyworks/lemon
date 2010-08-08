Covers 'lemon/controller/coverage_analyzer'

TestCase Lemon::CoverageAnalyzer do

  Instance "Coverage of public units of an incomplete test" do
    @memo_instance ||= (
      files = [File.dirname(__FILE__) + '/fixtures/case_incomplete.rb']
      Lemon::CoverageAnalyzer.new(files)
    )
  end

  Unit :covered => 'returns a list of covered units' do |ca|
    ca.covered.assert.is_a?(Array)
  end

  Unit :uncovered => 'returns a list of uncovered units' do |ca|
    ca.uncovered.assert.is_a?(Array)
  end

  Unit :current => 'returns a current Snapshot of all units in the system' do |ca|
    ca.current.assert.is_a?(Lemon::Snapshot)
  end

end

