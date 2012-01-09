require 'fakefs/safe'
require 'penchant'

Before('@fakefs') do
  FakeFS.activate!
end

After do
  FakeFS.deactivate!

  FileUtils.rm_rf 'tmp'
end

