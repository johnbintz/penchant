Given /^I expect git hooks to be installed$/ do
  Penchant::Hooks.expects(:install!)
end
