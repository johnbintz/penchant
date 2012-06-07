When /^I request the list of environments available$/ do
  @environments = Penchant::Gemfile.available_environments
end
