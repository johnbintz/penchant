Given /^I have the file "([^"]*)" with the content:$/ do |file, string|
  FileUtils.mkdir_p File.dirname(file)

  File.open(file, 'wb') { |fh| fh.print string }
end
