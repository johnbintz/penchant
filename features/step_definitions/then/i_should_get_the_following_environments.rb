Then /^I should get the following environments:$/ do |table|
  @environments.collect(&:to_s).sort.should == table.raw.flatten.sort
end
