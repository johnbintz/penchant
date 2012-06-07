Then /^I should get the following repositories:$/ do |table|
  @repos.collect(&:to_s).sort.should == table.raw.flatten.sort
end

