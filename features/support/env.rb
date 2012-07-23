require 'fakefs/safe'
require 'penchant'
require 'mocha'

World(Mocha::API)

Before('@fakefs') do
  FakeFS.activate!
end

Before('@mocha') do
  mocha_setup
end

After do
  FakeFS::FileSystem.clear
  FakeFS.deactivate!

  begin
    mocha_verify
  ensure
    mocha_teardown
  end

  FileUtils.rm_rf 'tmp'
end

