When "Given an example script in '(((.*?)))' as follows" do |name, text|
  name = File.join('tmp', name) if /^tmp/ !~ name
  FileUtils.mkdir_p(File.dirname(name))
  File.open(name, 'w'){ |w| w << text }
end

When "And given a test case in '(((.*?)))' as follows"  do |name, text|
  name = File.join('tmp', name) if /^tmp/ !~ name
  FileUtils.mkdir_p(File.dirname(name))
  File.open(name, 'w'){ |w| w << text }
end

