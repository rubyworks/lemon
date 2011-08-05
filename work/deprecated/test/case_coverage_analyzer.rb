covers 'lemon/controller/coverage_analyzer'

testcase Lemon::CoverageAnalyzer do

  setup "Coverage of public units of an incomplete test" do
    @memo_instance ||= (
      files = ['test/fixtures/case_incomplete.rb']
      Lemon::CoverageAnalyzer.new(files)
    )
  end

  unit :covered => 'returns a list of covered units' do |ca|
    ca.covered.assert.is_a?(Array)
  end

  unit :uncovered => 'returns a list of uncovered units' do |ca|
    ca.uncovered.assert.is_a?(Array)
  end

  unit :current => 'returns a current Snapshot of all units in the system' do |ca|
    ca.current.assert.is_a?(Lemon::Snapshot)
  end

end

