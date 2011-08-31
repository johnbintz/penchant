require 'spec_helper'

describe Penchant::DotPenchant do
  include FakeFS::SpecHelpers

  describe '.run' do
    before do
      File.open('.penchant', 'wb') { |fh|
        fh.puts "@did_run = env"
      }
    end

    it 'should run the file in the environment' do
      dot_file = Penchant::DotPenchant.run(:this)

      dot_file.instance_variable_get(:@did_run).should == :this
    end
  end
end

