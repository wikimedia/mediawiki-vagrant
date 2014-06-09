require 'spec_helper'

describe 'rbenv::plugin' do
  describe 'install ruby-build' do
    let(:title) { 'sstephenson/ruby-build' }
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) do
      {
        :install_dir => '/usr/local/rbenv',
      }
    end

    it { should contain_class('rbenv') }
    it { should contain_exec("install-sstephenson/ruby-build") }
    it { should contain_exec("rbenv-permissions-sstephenson/ruby-build") }
  end
end
