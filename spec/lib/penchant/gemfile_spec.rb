require 'spec_helper'

describe Penchant::Gemfile do
  include FakeFS::SpecHelpers

  let(:dir) { File.expand_path(Dir.pwd) }
  let(:gemfile) { described_class.new(dir) }

  let(:gemfile_path) { File.join(dir, 'Gemfile') }
  let(:gemfile_erb_path) { File.join(dir, 'Gemfile.erb') }

  def write_file(path, content = nil)
    FileUtils.mkdir_p(File.dirname(path))

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
    let(:data) { "whatever" }

    before do
      write_file(gemfile_path) { data }
    end

    describe 'existence' do
      it { should have_gemfile }
      it { should_not have_gemfile_erb }
    end

    describe '#environment' do
      context 'not defined' do
        its(:environment) { should be_nil }
      end

      context 'defined' do
        let(:environment) { 'test' }
        let(:data) { <<-GEMFILE }
# generated by penchant, environment: #{environment}
GEMFILE

        its(:environment) { should == environment }
        it { should_not be_deployment }
      end

      context 'deployment' do
        let(:environment) { 'test' }
        let(:data) { <<-GEMFILE }
# generated by penchant, environment: #{environment}, deployment mode
GEMFILE

        its(:environment) { should == environment }
        it { should be_deployment }
      end
    end

    describe '#switch_to!' do
      it 'should raise an exception' do
        expect { subject.switch_to!(:whatever) }.to raise_error(Errno::ENOENT)
      end
    end
  end

  context 'with gemfile.erb' do
    let(:erb_data) { 'whatever' }

    before do
      write_file(gemfile_erb_path) { erb_data }
    end

    it { should_not have_gemfile }
    it { should have_gemfile_erb }

    describe '#switch_to!' do
      let(:erb_data) { <<-ERB }
<% env :test do %>
  test
<% end %>

<% env :not do %>
  not
<% end %>

<% no_deployment do %>
  diddeploy
<% end %>

all
ERB

      it 'should render test data' do
        subject.switch_to!(:test)

        File.read('Gemfile').should include('test')
        File.read('Gemfile').should include('diddeploy')
        File.read('Gemfile').should_not include('not')
        File.read('Gemfile').should include('all')
      end

      it 'should not render test data' do
        subject.switch_to!(:not)

        File.read('Gemfile').should_not include('test')
        File.read('Gemfile').should include('diddeploy')
        File.read('Gemfile').should include('not')
        File.read('Gemfile').should include('all')
      end

      it 'should not render either' do
        subject.switch_to!

        File.read('Gemfile').should_not include('test')
        File.read('Gemfile').should_not include('not')
        File.read('Gemfile').should include('diddeploy')
        File.read('Gemfile').should include('all')
      end

      it 'should skip no_deployment sections' do
        subject.switch_to!(nil, true)

        File.read('Gemfile').should_not include('test')
        File.read('Gemfile').should_not include('not')
        File.read('Gemfile').should_not include('diddeploy')
        File.read('Gemfile').should include('all')
      end

      it { should_not have_dot_penchant }

      context 'with .penchant' do
        before do
          File.open('.penchant', 'wb')
        end

        it { should have_dot_penchant }

        it 'should process the file' do
          subject.switch_to!(:not)
        end
      end
    end
  end

  describe '#switch_to!' do
    let(:template) { 'source' }
    let(:gemfile_path) { 'gemfile path' }
    let(:header) { 'header' }

    let(:gemfile_out) { File.read(gemfile_path) }

    before do
      gemfile.stubs(:template).returns(template)
      gemfile.stubs(:gemfile_path).returns(gemfile_path)

      gemfile.expects(:header).returns(header)
    end

    it 'should write out the new gemfile' do
      gemfile.switch_to!

      gemfile_out.should include(template)
      gemfile_out.should include(header)
    end
  end

  describe '#header' do
    subject { gemfile.header }

    let(:env) { 'env' }
    let(:prior_environment) { 'prior' }

    before do
      gemfile.stubs(:current_env).returns(env)
      gemfile.stubs(:environment).returns(prior_environment)
    end

    context 'not deployment' do
      before do
        gemfile.stubs(:is_deployment).returns(false)
      end

      it { should == "# generated by penchant, environment: #{env}" }
    end

    context 'deployment' do
      before do
        gemfile.stubs(:is_deployment).returns(true)
      end

      it { should == "# generated by penchant, environment: #{env}, deployment mode (was #{prior_environment})" }
    end
  end

  describe '#prior_environment' do
    subject { gemfile.prior_environment }

    let(:prior) { 'prior' }

    before do
      gemfile.stubs(:gemfile_header).returns("# header (was #{prior})")
    end

    it { should == prior }
  end

  describe '.switch_back!' do
    let(:gemfile) { stub }
    let(:fallback_env) { 'env' }

    context 'pre_switch fails' do
      before do
        described_class.stubs(:pre_switch).returns(false)

        gemfile.expects(:switch_back!).never
      end

      it 'should not switch back' do
        described_class.switch_back!(fallback_env).should be_false
      end
    end

    context 'pre_switch succeeds' do
      before do
        described_class.stubs(:pre_switch).returns(gemfile)

        gemfile.expects(:switch_back!).with(fallback_env)
      end

      it 'should switch back' do
        described_class.switch_back!(fallback_env)
      end
    end
  end

  describe '.pre_switch' do
    subject { described_class.pre_switch(env, deployment) }

    let(:env) { 'env' }
    let(:deployment) { 'deployment' }

    context 'no Gemfile.erb' do
      before do
        described_class.any_instance.expects(:has_gemfile_erb?).returns(false)
      end

      it { should be_false }
    end

    context 'Gemfile.erb' do
      before do
        described_class.any_instance.expects(:has_gemfile_erb?).returns(true)
        described_class.any_instance.expects(:run_dot_penchant!).with(env, deployment)
      end

      it { should be_a_kind_of(described_class) }
    end
  end

  describe '#switch_back!' do
    let(:fallback_env) { 'fallback' }
    let(:prior) { 'prior' }

    context 'no prior' do
      before do
        gemfile.stubs(:prior_environment).returns(nil)

        gemfile.expects(:switch_to!).with(fallback_env)
      end

      it 'should proxy through to switch_to!' do
        gemfile.switch_back!(fallback_env)
      end
    end

    context 'prior' do
      before do
        gemfile.stubs(:prior_environment).returns(prior)

        gemfile.expects(:switch_to!).with(prior)
      end

      it 'should proxy through to switch_to!' do
        gemfile.switch_back!(fallback_env)
      end
    end
  end
end

