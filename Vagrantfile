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
# Please report bugs in this file on Wikimedia's Phabricator:
# https://phabricator.wikimedia.org/project/profile/627/
#
# Patches and contributions are welcome!
# http://www.mediawiki.org/wiki/How_to_become_a_MediaWiki_hacker
#

# The .vagrantplugins loading mechanism we use was added in v1.7.0
Vagrant.require_version '>= 1.7.0'

require 'ipaddr'
require 'socket'

mwv = MediaWikiVagrant::Environment.new(File.expand_path('..', __FILE__))
settings = mwv.load_settings

Vagrant.configure('2') do |config|
  config.vm.hostname = 'mediawiki-vagrant.dev'
  config.package.name = 'mediawiki.box'

  config.ssh.forward_agent = settings[:forward_agent]
  config.ssh.forward_x11 = settings[:forward_x11]

  # Default VirtualBox provider
  config.vm.provider :virtualbox do |_vb, override|
    override.vm.box = 'debian/contrib-jessie64'
    override.vm.network :private_network, ip: settings[:static_ip]
  end

  # VMWare Fusion provider. Enable with `--provider=vmware_fusion`
  # config.vm.provider :vmware_fusion do |_vw, override|
  #   override.vm.box = 'puppetlabs/ubuntu-14.04-64-puppet'
  #   override.vm.box_version = '1.0.1'
  #   override.vm.network :private_network, ip: settings[:static_ip]
  # end

  # Microsoft Hyper-V provider. Enable with `--provider=hyperv`
  # Not quite in 'just works' shape yet.
  #
  # You must run vagrant from an administrator shell to interact
  # with the Hyper-V virtual machines...
  #
  # Note you must configure networking manually in Hyper-V Manager!
  # NAT and port redirection are not automatically set up for you.
  #
  # config.vm.provider :hyperv do |_hyperv, override|
  #   # Our default box doesn't have Hyper-V support...
  #   override.vm.box = 'cirex/ubuntu-14.04'

  #   override.vm.network :private_network, ip: settings[:static_ip]
  # end

  # LXC provider. Enable wtih `--provider=lxc`
  # Requires vagrant-lxc plugin and Vagrant 1.7+
  config.vm.provider :lxc do |_lxc, override|
    override.vm.box = 'LEAP/jessie'
  end

  # Parallels provider. Enable with `--provider=parallels`
  #
  # Requires plugins:
  #   * Parallels provider - http://parallels.github.io/vagrant-parallels/
  #     $ vagrant plugin install vagrant-parallels
  #   * Puppet installer - https://github.com/petems/vagrant-puppet-install
  #     $ vagrant plugin install vagrant-puppet-install
  #
  # Note that port forwarding works via localhost but not via external interfaces
  # of the host machine by default...
  # config.vm.provider :parallels do |_parallels, override|
  #   override.vm.box = 'parallels/ubuntu-14.04'

  #   # Pin to a 3.x version, current as of this config writing.
  #   override.puppet_install.puppet_version = '3.7.4'

  #   override.vm.network :private_network, ip: settings[:static_ip]
  # end

  # libvirt (KVM/QEMU) provider.  Enable with `--provider=libvirt`.
  # config.vm.provider :libvirt do |_libvirt, override|
  #   override.vm.box = 'trusty-cloud'

  #   override.vm.network :private_network, ip: settings[:static_ip]
  # end

  config.vm.network :forwarded_port,
    guest: 80, host: settings[:http_port], host_ip: settings[:host_ip],
    id: 'http'

  config.vm.network :forwarded_port,
    guest: 443, host: settings[:https_port], host_ip: settings[:host_ip],
    id: 'https'

  unless settings[:forward_ports].nil?
    settings[:forward_ports].each do |guest_port, host_port|
      config.vm.network :forwarded_port,
        host: host_port, host_ip: settings[:host_ip],
        guest: guest_port, auto_correct: true
    end
  end

  root_share_options = { id: 'vagrant-root' }

  if settings[:nfs_shares]
    root_share_options[:type] = :nfs
    root_share_options[:mount_options] = ['noatime', 'rsize=32767', 'wsize=32767', 'async']
    root_share_options[:mount_options] << 'fsc' if settings[:nfs_cache]
    root_share_options[:mount_options] << 'vers=3' if settings[:nfs_force_v3]
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid
  else
    root_share_options[:owner] = 'vagrant'
    root_share_options[:group] = 'www-data'
  end

  config.vm.synced_folder '.', '/vagrant', root_share_options

  unless settings[:nfs_shares]
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

    # Prevent clock drift, see http://stackoverflow.com/a/19492466/323407
    vb.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10000]

    # To boot the VM in graphical mode, uncomment the following line:
    # vb.gui = true
  end

  config.vm.provider :vmware_fusion do |vw|
    vw.vmx['memsize'] = settings[:vagrant_ram]
    vw.vmx['numvcpus'] = settings[:vagrant_cores]

    # To boot the VM in graphical mode, uncomment the following line:
    # vw.gui = true
  end

  config.vm.provider :lxc do |lxc|
    lxc.customize 'cgroup.memory.limit_in_bytes', "#{settings[:vagrant_ram]}M"
    lxc.backingstore = 'none'
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = 'qemu'
    libvirt.memory = settings[:vagrant_ram]
    libvirt.cpus   = settings[:vagrant_cores]
  end

  config.vm.provision :lsb_check do |lsb|
    lsb.vendor = 'Debian'
    lsb.version = '8.6'
  end

  config.vm.provision :mediawiki_reload if mwv.reload?

  # Ensure that the VM has Puppet installed
  config.vm.provision :shell, path: 'support/puppet-bootstrap.sh'

  config.vm.provision :puppet do |puppet|
    # Use empty module path to avoid an extra mount.
    # See --modulepath below
    puppet.module_path = []

    # Tell Vagrant that the manifests are already on the guest
    puppet.manifests_path = [:guest, '/vagrant/puppet/manifests']
    puppet.manifest_file = 'site.pp'

    puppet.options = [
      '--modulepath', '/vagrant/puppet/modules',
      '--hiera_config', '/vagrant/puppet/hiera.yaml',
      '--verbose',
      '--config_version', '/vagrant/puppet/extra/config-version',
      '--logdest', "/vagrant/logs/puppet/puppet.#{mwv.commit || 'unknown'}.log",
      '--logdest', 'console',
      '--write-catalog-summary',
      '--detailed-exitcodes',
    ]

    # Handy debugging commands for Puppet runs
    puppet.options << '--evaltrace' if ENV.include?('PUPPET_EVAL_TRACE')
    puppet.options << '--debug' if ENV.include?('PUPPET_DEBUG')

    # Windows's Command Prompt has poor support for ANSI escape sequences.
    puppet.options << '--color=false' if Vagrant::Util::Platform.windows?

    puppet.facter = {
      'fqdn'                   => config.vm.hostname,
      'git_user'               => settings[:git_user],
      'forwarded_port'         => settings[:http_port],
      'forwarded_https_port'   => settings[:https_port],
      'shared_apt_cache'       => '/vagrant/cache/apt/',
      'environment'            => ENV['MWV_ENVIRONMENT'] || 'vagrant',
      'vmhost'                 => Socket.gethostname,
      # T86282: Force Puppet's LANG env var by exploiting a factor quirk.
      # See https://stackoverflow.com/a/23502693/582542
      'x=x LANG=en_US.UTF-8 x' => 'x',
    }

    if settings[:http_port] != 80 && ENV['MWV_ENVIRONMENT'] != 'labs'
      puppet.facter['port_fragment'] = ":#{settings[:http_port]}"
    end

    if settings[:nfs_shares]
      puppet.facter['share_owner'] = Process.uid
      puppet.facter['share_group'] = Process.gid
    else
      puppet.facter['share_owner'] = 'vagrant'
      puppet.facter['share_group'] = 'www-data'
    end

    # Derive a host IP from the configured static IP by getting the first
    # usable IP in the 8-bit network
    if settings[:static_ip]
      network = IPAddr.new("#{settings[:static_ip]}/24")
      puppet.facter['host_ip'] = network.to_range.take(2).last.to_s
    end
  end
end

# Load custom Vagrantfile overrides from 'Vagrantfile-extra.rb'
# See 'support/Vagrantfile-extra.rb' for an example but make sure to folow
# the instructions in that file.  In particular it is important to copy it
# to the parent directory.  Editing it without copying it will only cause
# sadness.
begin
  require mwv.path('Vagrantfile-extra').to_s
rescue LoadError
end
