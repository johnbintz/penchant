Then /^the output should include "([^"]*)"$/ do |text|
  @output.should include(text)
end
