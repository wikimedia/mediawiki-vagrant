# Copyright (c) 2011 Robert Schulze <robert@dotless.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant VBGuest plugin must be run within Vagrant."
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../vagrant-vbguest.yml", __FILE__)

require "vagrant-vbguest/errors"
require 'vagrant-vbguest/vagrant_compat'

require 'vagrant-vbguest/machine'

require 'vagrant-vbguest/hosts/base'
require 'vagrant-vbguest/hosts/virtualbox'

require 'vagrant-vbguest/installer'
require 'vagrant-vbguest/installers/base'
require 'vagrant-vbguest/installers/linux'
require 'vagrant-vbguest/installers/debian'
require 'vagrant-vbguest/installers/ubuntu'
require 'vagrant-vbguest/installers/redhat'

require 'vagrant-vbguest/middleware'

module VagrantVbguest

  class Plugin < Vagrant.plugin("2")

    name "vagrant-vbguest"
    description <<-DESC
    Provides automatic and/or manual management of the
    VirtualBox Guest Additions inside the Vagrant environment.
    DESC

    config('vbguest') do
      require File.expand_path("../vagrant-vbguest/config", __FILE__)
      Config
    end

    command('vbguest') do
      Command
    end

    # hook after anything that boots:
    # that's all middlewares which will run the buildin "VM::Boot" action
    action_hook('vbguest') do |hook|
      if defined?(VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions)
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::CheckGuestAdditions, VagrantVbguest::Middleware)
      else
        hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, VagrantVbguest::Middleware)
      end
    end
  end
end
