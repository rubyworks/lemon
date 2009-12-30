#

testcase Lemon::Coverage do

  #Before /returns/ do |unit|
  #  puts "returns something"
  #end

  unit :coverage => 'returns a chart of coverage' do
    #X.new.a.assert.is_a?(String)
  end

  unit :cover => 'returns a pre-checked chart of potential coverage' do
    #X.new.a.assert =~ /^[a-z]*$/
  end

  unit :system => 'returns a list of classes/modules currently in the Ruby proccess' do
    #1.assert == 4
  end

  #unit :snapshot => 'can be broken' do
  #  #1.assert == 4
  #end

end

