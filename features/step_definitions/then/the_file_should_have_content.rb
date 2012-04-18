Then /^the file "([^"]*)" should have the following content:$/ do |file, string|
  File.read(file).should == string
end
