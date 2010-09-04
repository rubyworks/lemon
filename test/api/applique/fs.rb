require 'fileutils'

Before :demo do
  FileUtils.rm_r('tmp')
end

When "Given an example script in '(((.*?)))' as follows" do |name, text|
  name = File.join('tmp', name) if /^tmp/ !~ name
  FileUtils.mkdir_p(File.dirname(name))
  File.open(name, 'w'){ |w| w << text }
end

When "given a test case in '(((.*?)))' as follows"  do |name, text|
  name = File.join('tmp', name) if /^tmp/ !~ name
  FileUtils.mkdir_p(File.dirname(name))
  File.open(name, 'w'){ |w| w << text }
end

