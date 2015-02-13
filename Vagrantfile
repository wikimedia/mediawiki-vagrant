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
# Simple configuration changes can be made by running the setup script (see
# README.md for details).
#
# Please report bugs in this file on Wikimedia's Bugzilla:
# https://bugzilla.wikimedia.org/enter_bug.cgi?product=MediaWiki-Vagrant
#
# Patches and contributions are welcome!
# http://www.mediawiki.org/wiki/How_to_become_a_MediaWiki_hacker
#
$DIR = File.expand_path('..', __FILE__)

# Ensure we're using the latest version of the plugin
require_relative 'lib/mediawiki-vagrant/version'
require 'fileutils'
require 'ipaddr'

# NOTE Use RubyGems over the Vagrant plugin manager as it's more reliable
gemspec = Gem::Specification.find { |s| s.name == 'mediawiki-vagrant' }
setup = Vagrant::Util::Platform.windows? ? 'setup.bat' : 'setup.sh'

if gemspec.nil?
    raise "The mediawiki-vagrant plugin hasn't been installed yet. Please run `#{setup}`."
else
    installed = gemspec.version
    latest = Gem::Version.new(MediaWikiVagrant::VERSION)
    raise "Your mediawiki-vagrant plugin isn't up-to-date. Please re-run `#{setup}`." unless Gem::Requirement.new(latest.approximate_recommendation).satisfied_by?(installed)
end

require 'mediawiki-vagrant/settings/definitions'

mwv = MediaWikiVagrant::Environment.new($DIR)
settings = mwv.load_settings('vagrant.d')

Vagrant.configure('2') do |config|
    config.vm.hostname = 'mediawiki-vagrant.dev'
    config.package.name = 'mediawiki.box'

    config.ssh.forward_agent = settings[:forward_agent]

    # Default VirtualBox provider
    config.vm.provider :virtualbox do |vb, override|
        override.vm.box = 'trusty-cloud'
        override.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
        override.vm.box_download_insecure = true
    end

    # VMWare Fusion provider. Enable with `--provider=vmware_fusion`
    config.vm.provider :vmware_fusion do |vw, override|
        override.vm.box = 'puppetlabs/ubuntu-14.04-64-puppet'
    end

    # Docker provider. Enable with `--provider=docker`
    config.vm.provider :docker do |docker, override|
        # Disable nfs shares for
        # https://github.com/mitchellh/vagrant/issues/4011
        override.nfs.functional = false
    end

    config.vm.network :private_network, ip: settings[:static_ip]

    config.vm.network :forwarded_port,
        guest: 80, host: settings[:http_port], id: 'http'

    settings[:forward_ports].each { |guest_port,host_port|
        config.vm.network :forwarded_port,
            :host => host_port, :guest => guest_port,
            auto_correct: true
    } unless settings[:forward_ports].nil?

    root_share_options = {:id => 'vagrant-root'}

    if settings[:nfs_shares]
        root_share_options[:type] = :nfs
        root_share_options[:mount_options] = ['noatime','rsize=32767','wsize=32767','async']
        config.nfs.map_uid = Process.uid
        config.nfs.map_gid = Process.gid
    else
        root_share_options[:owner] = 'vagrant'
        root_share_options[:group] = 'www-data'
    end

    config.vm.synced_folder '.', '/vagrant', root_share_options

    if !settings[:nfs_shares]
        # www-data needs to write to the logs, but doesn't need write
        # access for all of /vagrant
        #
        # Users of NFS should not need this special export because of the
        # global uid/gid map used for the NFS export. Attempts from within the
        # VM to chmod files and folders to www-data:www-data will fail
        # however, so avoid that in puppet code and account for it in shell
        # scripts.
        config.vm.synced_folder './logs', '/vagrant/logs',
            id: 'vagrant-logs',
            owner: 'www-data',
            group: 'www-data'
    end

    config.vm.provider :virtualbox do |vb|
        # See http://www.virtualbox.org/manual/ch08.html for additional options.
        vb.customize ['modifyvm', :id, '--memory', settings[:vagrant_ram]]
        vb.customize ['modifyvm', :id, '--cpus', settings[:vagrant_cores]]
        vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
        vb.customize ['modifyvm', :id, '--ioapic', 'on']  # Bug 51473

        # Speed up dns resolution in some cases
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']

        # To boot the VM in graphical mode, uncomment the following line:
        # vb.gui = true
    end

    config.vm.provider :vmware_fusion do |vw|
        vw.vmx['memsize'] = settings[:vagrant_ram]
        vw.vmx['numvcpus'] = settings[:vagrant_cores]

        # To boot the VM in graphical mode, uncomment the following line:
        #vw.gui = true
    end

    config.vm.provider :docker do |docker|
        docker.build_dir = './support/docker'
        docker.create_args = ['-i', '-t']
        docker.has_ssh = true
        docker.remains_running = true
        docker.privileged = true
    end

    config.vm.provision :lsb_check do |lsb|
        lsb.version = '14.04'
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = 'puppet/modules'
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'
        puppet.hiera_config_path = 'puppet/hiera.yaml'

        puppet.options = [
            '--templatedir', '/vagrant/puppet/templates',
            '--verbose',
            '--config_version', '/vagrant/puppet/extra/config-version',
            '--fileserverconfig', '/vagrant/puppet/extra/fileserver.conf',
            '--logdest', "/vagrant/logs/puppet/puppet.#{mwv.commit || 'unknown'}.log",
            '--logdest', 'console',
            '--write-catalog-summary',
        ]

        # For more output, uncomment the following line:
        puppet.options << '--debug' if ENV.include?('PUPPET_DEBUG')

        # Windows's Command Prompt has poor support for ANSI escape sequences.
        puppet.options << '--color=false' if Vagrant::Util::Platform.windows?

        puppet.facter = $FACTER = {
            'fqdn'               => config.vm.hostname,
            'forwarded_port'     => settings[:http_port],
            'shared_apt_cache'   => '/vagrant/cache/apt/',
            'environment'        => 'vagrant',
        }

        if settings[:http_port] != 80
            $FACTER['port_fragment'] = ":#{settings[:http_port]}"
        end

        if settings[:nfs_shares]
            $FACTER['share_owner'] = Process.uid
            $FACTER['share_group'] = Process.gid
        else
            $FACTER['share_owner'] = 'vagrant'
            $FACTER['share_group'] = 'www-data'
        end

        # Derive a host IP from the configured static IP by getting the first
        # usable IP in the 8-bit network
        if settings[:static_ip]
            network = IPAddr.new("#{settings[:static_ip]}/24")
            $FACTER['host_ip'] = network.to_range.take(2).last.to_s
        end
    end

    if Vagrant.plugin('2').manager.provisioners[:mediawiki_reload] && \
        File.exists?(File.join($DIR, 'vagrant.d', 'RELOAD'))
        config.vm.provision :mediawiki_reload
    end
end



# Migrate {apt,composer}-cache to cache/{apt,composer}
['apt', 'composer'].each do |type|
    src = File.join $DIR, "#{type}-cache"
    if File.directory? src
        dst = File.join $DIR, 'cache', type
        Dir.foreach(src) do |f|
            next if File.directory? f or f.start_with? '.'
            File.rename(File.join(src, f), File.join(dst, f)) rescue nil
        end rescue nil
    end
end

# Load custom Vagrantfile overrides from 'Vagrantfile-extra.rb'
# See 'support/Vagrantfile-extra.rb' for an example but make sure to folow
# the instructions in that file.  In particular it is important to copy it
# to the parent directory.  Editing it without copying it will only cause
# sadness.
begin
    require File.join($DIR, 'Vagrantfile-extra')
rescue LoadError
end
