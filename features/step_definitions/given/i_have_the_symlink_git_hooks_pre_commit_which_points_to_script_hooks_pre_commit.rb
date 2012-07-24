Given /^I have the symlink "(.*?)" which points to "(.*?)"$/ do |source, target|
  FileUtils.mkdir_p(File.dirname(source))
  File.symlink(target, source)
end
