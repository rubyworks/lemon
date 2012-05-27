require 'fileutils'

#Before :demo do
#  FileUtils.rm_r('lib')
#  FileUtils.rm_r('test')
#end

When "Given an example script in '(((.*?)))' as follows" do |name, text|
  #name = File.join('tmp', name) if /^tmp/ !~ name
  dir = File.dirname(name)
  FileUtils.mkdir_p(dir) unless File.directory?(dir)
  File.open(name, 'w'){ |w| w << text }
end

When "given a test case in '(((.*?)))' as follows"  do |name, text|
  #name = File.join('tmp', name) if /^tmp/ !~ name
  dir = File.dirname(name)
  FileUtils.mkdir_p(dir) unless File.directory?(dir)
  File.open(name, 'w'){ |w| w << text }
end

