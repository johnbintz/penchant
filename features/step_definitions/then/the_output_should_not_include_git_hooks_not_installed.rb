Then /^the output should not include "(.*?)"$/ do |text|
  @output.should_not include(text)
end
