require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'cucumber'
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = "features --format pretty"
  end
rescue LoadError
  "#$! - no cucumber"
end

task :default => [ :cucumber ]

