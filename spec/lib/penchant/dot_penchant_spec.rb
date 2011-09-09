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

  let(:dot_file) { described_class.new }

  describe '#rake' do
    context 'without Gemfile' do
      before do
        Kernel.expects(:system).with('rake task1 task2')
      end

      it 'should run the rake task via system' do
        dot_file.rake("task1", "task2")
      end
    end

    context 'with Gemfile' do
      before do
        File.open('Gemfile', 'wb')
        Kernel.expects(:system).with('bundle exec rake task1 task2')
      end

      it 'should run the rake task via system' do
        dot_file.rake("task1", "task2")
      end
    end
  end
end

