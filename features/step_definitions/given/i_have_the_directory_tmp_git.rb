Given /^I have the directory "(.*?)"$/ do |dir|
  FileUtils.mkdir_p dir
end
