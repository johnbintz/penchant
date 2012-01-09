When /^I rebuild the Gemfile for "([^"]*)" mode with deployment$/ do |env|
  Penchant::Gemfile.do_full_env_switch!(env, true)
end
