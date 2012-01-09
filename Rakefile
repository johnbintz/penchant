require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  "#$! - no rspec"
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  "#$! - no rspec"
end

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = "features --format pretty"
  end
rescue LoadError
  "#$! - no cucumber"
end

task :default => [ :spec, :cucumber ]

