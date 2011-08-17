require 'spec_helper'

describe Penchant::Gemfile do
  include FakeFS::SpecHelpers

  let(:dir) { File.expand_path(Dir.pwd) }
  let(:gemfile) { described_class.new(dir) }

  let(:gemfile_path) { File.join(dir, 'Gemfile') }
  let(:gemfile_erb_path) { File.join(dir, 'Gemfile.erb') }

  def write_file(path, content = nil)
    File.open(path, 'wb') do |fh|
      content = yield if block_given?
      fh.print content
    end
  end

  subject { gemfile }

  context 'with no gemfile' do
    it { should_not have_gemfile }
    it { should_not have_gemfile_erb }
  end

  context 'with gemfile' do
    before do
      write_file(gemfile_path) { "whatever" }
    end

    it { should have_gemfile }
    it { should_not have_gemfile_erb }
  end

  context 'with gemfile.erb' do
    before do
      write_file(gemfile_erb_path) { "whatever" }
    end

    it { should_not have_gemfile }
    it { should have_gemfile_erb }
  end
end

