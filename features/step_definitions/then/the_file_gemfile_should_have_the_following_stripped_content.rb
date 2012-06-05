Then /^the file "(.*?)" should have the following stripped content:$/ do |file, string|
  test_lines = string.lines.to_a

  File.read(file).lines.collect(&:strip).reject(&:empty?).to_a.each do |line|
    line.strip.should == test_lines.shift.strip
  end
end
