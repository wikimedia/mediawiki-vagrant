# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile for Mediawiki-Vagrant
# ---------------------------------
# http://www.mediawiki.org/wiki/Mediawiki-Vagrant
#
# This file contains the Vagrant configurations for provisioning a MediaWiki
# development instance. Vagrant file uses Ruby as a configuration language.
#
# The file's structure and content are described in the Vagrant docs:
# http://docs.vagrantup.com/v2/vagrantfile/index.html
#
# If you would like to customize the configuration of your Virtual Machine,
# rather than override the values defined in this file, simply create a file
# called 'Vagrantfile-extra.rb' in this folder and it will be automatically
# loaded. In case of conflict, values in the 'extra' file will superceded
# any values in this file. 'Vagrantfile-extra.rb' is ignored by git.
#
# Please report bugs in this file on Wikimedia's Bugzilla:
# https://bugzilla.wikimedia.org/enter_bug.cgi?product=MediaWiki-Vagrant
#
# Patches and contributions are welcome!
# http://www.mediawiki.org/wiki/How_to_become_a_MediaWiki_hacker
#
$DIR = File.expand_path('..', __FILE__); $: << File.join($DIR, 'lib')
require 'mediawiki-vagrant'

begin
    require 'vagrant-vbguest'
rescue Exception => msg
    puts "[Warning] Failed to load vagrant-vbguest plugin: #{msg}"
end

Vagrant.configure('2') do |config|
    config.vm.hostname = 'mediawiki-vagrant.dev'
    config.package.name = 'mediawiki.box'

    # Note: If you rely on Vagrant to retrieve the box, it will not
    # verify SSL certificates. If this concerns you, you can retrieve
    # the file using another tool that implements SSL properly, and then
    # point Vagrant to the downloaded file:
    #   $ vagrant box add precise-cloud /path/to/file/precise.box
    config.vm.box = 'precise-cloud'
    config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
    if config.vm.respond_to? 'box_download_insecure'  # Vagrant 1.2.6+
        config.vm.box_download_insecure = true
    end

    config.vm.network :private_network,
        ip: '10.11.12.13'

    # The port on the host that should be forwarded to the guest's HTTP server.
    FORWARDED_PORT = 8080

    config.vm.network :forwarded_port,
        guest: 80, host: FORWARDED_PORT, id: 'http'

    config.vm.synced_folder '.', '/vagrant',
        id: 'vagrant-root',
        owner: 'vagrant',
        group: 'www-data'

    # www-data needs to write to the logs, but doesn't need write
    # access for all of /vagrant
    config.vm.synced_folder './logs', '/vagrant/logs',
        id: 'vagrant-logs',
        owner: 'www-data',
        group: 'www-data'

    config.vm.provider :virtualbox do |vb|
        # See http://www.virtualbox.org/manual/ch08.html for additional options.
        vb.customize ['modifyvm', :id, '--memory', '1024']
        vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
        vb.customize ['modifyvm', :id, '--ioapic', 'on']  # Bug 51473

        # To boot the VM in graphical mode, uncomment the following line:
        # vb.gui = true

        # If you are on a single-core system, comment out the following line:
        vb.customize ['modifyvm', :id, '--cpus', '2']
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = 'puppet/modules'
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'

        puppet.options = [
            '--templatedir', '/vagrant/puppet/templates',
            '--verbose',
            '--config_version', '/vagrant/puppet/extra/config-version',
            '--fileserverconfig', '/vagrant/puppet/extra/fileserver.conf',
            '--logdest', "/vagrant/logs/puppet/puppet.#{commit||'unknown'}.log",
            '--logdest', 'console',
        ]

        # For more output, uncomment the following line:
        # puppet.options << '--debug'

        # Windows's Command Prompt has poor support for ANSI escape sequences.
        puppet.options << '--color=false' if windows?

        puppet.facter = $FACTER = {
            'fqdn'               => config.vm.hostname,
            'forwarded_port'     => FORWARDED_PORT,
            'shared_apt_cache'   => '/vagrant/apt-cache/',
        }
    end
end


begin
    # Load custom Vagrantfile overrides from 'Vagrantfile-extra.rb'
    # See 'support/Vagrantfile-extra.rb' for an example but make sure to folow
    # the instructions in that file.  In particular it is important to copy it
    # to the parent directory.  Editing it without copying it will only cause
    # sadness.
    require File.join($DIR, 'Vagrantfile-extra')
rescue LoadError
    # OK. File does not exist.
end
