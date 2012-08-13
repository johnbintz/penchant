Then /^the file "(.*?)" should include the following content:$/ do |file, string|
  File.read(file).should include(string)
end
