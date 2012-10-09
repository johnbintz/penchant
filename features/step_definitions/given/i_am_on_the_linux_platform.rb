Given /^I am on the "([^"]*)" platform$/ do |os|
  Penchant::FileProcessor.any_instance.stubs(:current_os).returns(os.to_sym)
end
