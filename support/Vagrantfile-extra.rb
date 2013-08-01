# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Sample 'extra' configuration file for MediaWiki-Vagrant
# -------------------------------------------------------
# http://www.mediawiki.org/wiki/Mediawiki-Vagrant
#
# This file contains examples of some customizations you may wish to
# apply to your virtual machine. To use it, copy this file to its parent
# directory (i.e., the repository root directory).
#
# To apply a customization, uncomment its line by removing the leading
# '#'. Then save the file and run 'vagrant halt' followed by 'vagrant up'.
#
# Useful details about the structure and content of this file can be
# found in the Vagrant documentation, at:
# <http://docs.vagrantup.com/v2/vagrantfile/index.html>.
#
Vagrant.configure('2') do |config|
    config.vm.provider :virtualbox do |vb|
        # For a full list of options you can pass to 'modifyvm', see
        # <http://www.virtualbox.org/manual/ch08.html>.

        # Boot the VM in graphical mode:
        # vb.gui = true

        # Increase memory allocation from 768MB to 1GB:
        # vb.customize ['modifyvm', :id, '--memory', '1024']

        # But limit the virtual machine to 1 CPU core:
        # vb.customize ['modifyvm', :id, '--cpus', '1']
    end

    # Forward MySQL port. This allows you to use a graphical database
    # management application on your host environment (like HeidiSQL or
    # Sequel Pro) to manage the database server running on the VM.
    # config.vm.network :forwarded_port,
    #    guest: 3306, host: 3306, id: 'mysql'
end
