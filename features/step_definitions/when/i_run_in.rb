When /^I run "([^"]*)" in the "([^"]*)" directory$/ do |command, dir|
  @output = %x{bash -c 'opwd=$PWD; cd #{dir} && $opwd/#{command}'}
end
