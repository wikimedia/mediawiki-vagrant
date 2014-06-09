require 'spec_helper'

describe 'rbenv::build' do
  describe 'install 2.0.0-p247' do
    let(:title) { '2.0.0-p247' }
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) do
      {
        :install_dir => '/usr/local/rbenv',
        :owner       => 'root',
        :group       => 'adm',
        :global      => false,
        :cflags      => '-O3 -march=native',
      }
    end

    it { should contain_class('rbenv') }

    it { should contain_exec("own-plugins-2.0.0-p247") }
    it { should contain_exec("git-pull-rubybuild-2.0.0-p247") }
    it { should contain_exec("rbenv-install-2.0.0-p247") }
    it { should contain_exec("rbenv-ownit-2.0.0-p247") }

    context 'with global => true' do
      let(:params) do
        {
          :install_dir => '/usr/local/rbenv',
          :owner       => 'root',
          :group       => 'adm',
          :global      => true,
          :cflags      => '-O3 -march=native',
        }
      end

      it { should contain_exec("rbenv-global-2.0.0-p247") }
    end

  end
end
