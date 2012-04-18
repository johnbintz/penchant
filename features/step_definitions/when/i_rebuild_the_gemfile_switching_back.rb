When /^I rebuild the Gemfile asking to switch back to the previous state$/ do
  Penchant::Gemfile.switch_back!("remote")
end
