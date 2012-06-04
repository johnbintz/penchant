When /^I rebuild the Gemfile for "(.*?)" mode$/ do |env|
  Penchant::Gemfile.do_full_env_switch!(env)
end

