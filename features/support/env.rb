require 'fakefs/safe'
require 'penchant'

Before('@fakefs') do
  FakeFS.activate!
end

After do
  FakeFS::FileSystem.clear
  FakeFS.deactivate!

  FileUtils.rm_rf 'tmp'
end

