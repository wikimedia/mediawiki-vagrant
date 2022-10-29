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

# workaround for T203145
if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('2.1.3')
  require 'mediawiki-vagrant/environment'
end

# T156380: Check to see if the legacy gem version of the plugin is installed
if Vagrant.has_plugin?('mediawiki-vagrant')
  raise <<-EOS

  The deprecated mediawiki-vagrant plugin is installed.

  Please remove it by running `vagrant plugin uninstall mediawiki-vagrant`.

  See https://phabricator.wikimedia.org/T156380 for details.
  EOS
end

mwv = MediaWikiVagrant::Environment.new(File.expand_path('..', __FILE__))
settings = mwv.load_settings

unless Vagrant::DEFAULT_SERVER_URL.frozen?
  # T187978: fix the base URL used to download new boxes.
  # See also: https://github.com/hashicorp/vagrant/issues/9442
  Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
end

Vagrant.configure('2') do |config|
  config.vm.post_up_message = 'Documentation: https://www.mediawiki.org/wiki/MediaWiki-Vagrant'
  config.package.name = 'mediawiki.box'

  config.ssh.forward_agent = settings[:forward_agent]
  config.ssh.forward_x11 = settings[:forward_x11]

  # Default VirtualBox provider
  config.vm.provider :virtualbox do |_vb, override|
    override.vm.box = 'debian/contrib-buster64'
    override.vm.network :private_network, ip: settings[:static_ip]
  end

  # VMWare Fusion provider. Enable with `--provider=vmware_fusion`
  ## FIXME: T271649 - need a Debian 10 (Buster) base image
  ## config.vm.provider :vmware_fusion do |_vw, override|
  ##   override.vm.box = 'generic/debian9'
  ##   override.vm.network :private_network, ip: settings[:static_ip]
  ## end

  # Microsoft Hyper-V provider. Enable with `--provider=hyperv`
  # Not quite in 'just works' shape yet.
  #
  # You must run vagrant from an administrator shell to interact
  # with the Hyper-V virtual machines...
  #
  # Note you must configure networking manually in Hyper-V Manager!
  # NAT and port redirection are not automatically set up for you.
  #
  config.vm.provider :hyperv do |_hyperv, override|
    override.vm.box = 'generic/debian10'
    override.vm.network :private_network, ip: settings[:static_ip]
  end

  # LXC provider. Enable wtih `--provider=lxc`
  # Requires vagrant-lxc plugin and Vagrant 1.7+
  config.vm.provider :lxc do |_lxc, override|
    override.vm.box = 'sagiru/buster-amd64'
  end

  # Parallels provider. Enable with `--provider=parallels`
  #
  # Requires plugins:
  #   * Parallels provider - http://parallels.github.io/vagrant-parallels/
  #     $ vagrant plugin install vagrant-parallels
  #
  # Note that port forwarding works via localhost but not via external
  # interfaces of the host machine by default...
  config.vm.provider :parallels do |_parallels, override|
    override.vm.box = 'generic/debian10'
    override.vm.network :private_network, ip: settings[:static_ip]
    _parallels.memory = settings[:vagrant_ram]
    _parallels.cpus = [settings[:vagrant_cores], 8].min
  end

  # libvirt (KVM/QEMU) provider.  Enable with `--provider=libvirt`.
  config.vm.provider :libvirt do |libvirt, override|
    override.vm.box = 'generic/debian10'
    override.vm.network :private_network, ip: settings[:static_ip]
    # Required on Fedora 30/31 to fix private networking
    # https://bugzilla.redhat.com/show_bug.cgi?id=1697773
    libvirt.qemu_use_session = false
  end

  config.vm.network :forwarded_port,
    guest: settings[:http_port], host: settings[:http_port], host_ip: settings[:host_ip],
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
    root_share_options[:mount_options] = ['noatime', 'rsize=32767', 'wsize=32767', 'async', 'nolock']
    root_share_options[:mount_options] << 'fsc' if settings[:nfs_cache]
    if settings[:nfs_force_v3]
      root_share_options[:mount_options] << 'vers=3'
    elsif settings[:nfs_force_v4]
      root_share_options[:nfs_version] = 4
      root_share_options[:nfs_udp] = false
    end
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid
  else
    root_share_options[:owner] = 'vagrant'
    root_share_options[:group] = 'www-data'
  end

  if settings[:smb_shares]
    root_share_options[:type] = :smb
    # mfsymlinks will allow the linux VM to make symlinks on the samba share
    # see https://wiki.samba.org/index.php/UNIX_Extensions#Minshall.2BFrench_symlinks for details
    root_share_options[:mount_options] = ['mfsymlinks', 'dir_mode=0755', 'file_mode=0755']
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

  # T69976: We used to install the vbguest plugin to ensure that VirtualBox
  # guest extensions matched on the host and VM. This turns out to be
  # semi-useful for an initial VM creation, but causes big problems once our
  # custom Puppet code has messed with default location of the apt cache
  # directories. The common fix given when asked on irc or Phabricator is to
  # disable the plugin, so lets cut out the middleman and just do that
  # preemptively in our Vagrantfile.
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  config.vm.provider :virtualbox do |vb|
    # See http://www.virtualbox.org/manual/ch08.html for additional options.
    vb.customize ['modifyvm', :id, '--memory', settings[:vagrant_ram]]
    vb.customize ['modifyvm', :id, '--cpus', settings[:vagrant_cores]]
    vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']
    vb.customize ['modifyvm', :id, '--ioapic', 'on']  # Bug 51473

    # The most recent versions of VirtualBox (5.1.x) seem to start the NAT
    # interface as disconnected (preventing startup), so we need to turn it
    # on explicitly. https://github.com/hashicorp/vagrant/issues/7648
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']

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
    if mwv.roles_enabled.include?('cirrussearch')
      lxc.customize 'aa_profile', 'unconfined'
    end
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = 'qemu'
    libvirt.memory = settings[:vagrant_ram]
    libvirt.cpus   = settings[:vagrant_cores]
  end

  config.vm.provision :lsb_check do |lsb|
    lsb.vendor = 'Debian'
    lsb.version = '^10'
  end

  config.vm.provision :mediawiki_reload if mwv.reload?

  config.vm.provision :file_perms

  # Ensure that the VM has Puppet installed
  config.vm.provision :shell, path: 'support/puppet-bootstrap.sh'

  config.vm.provision :puppet do |puppet|
    # Use empty module path to avoid an extra mount.
    # See --modulepath below
    puppet.module_path = []

    # Tell Vagrant that the manifests are already on the guest
    puppet.manifests_path = [:guest, '/vagrant/puppet/manifests']
    puppet.manifest_file = 'site.pp'

    puppet.environment_path = [:guest, '/vagrant/puppet/environments']
    puppet.environment = ENV['MWV_ENVIRONMENT'] || 'vagrant'

    puppet.options = [
      '--modulepath', '/vagrant/puppet/modules',
      '--hiera_config', '/vagrant/puppet/hiera.yaml',
      '--verbose',
      '--config_version', '/vagrant/puppet/extra/config-version',
      '--logdest', 'console',
      # NOTE: setting multiple --logdest destinations is broken in Puppet
      # >=5.5.7,<5.5.14. See https://tickets.puppetlabs.com/browse/PUP-9565
      '--logdest', "/vagrant/logs/puppet/puppet.#{mwv.commit || 'unknown'}.log",
      '--write-catalog-summary',
      '--detailed-exitcodes',
      '--ordering manifest',
    ]

    # Handy debugging commands for Puppet runs
    puppet.options << '--evaltrace' if ENV.include?('PUPPET_EVAL_TRACE')
    puppet.options << '--debug' if ENV.include?('PUPPET_DEBUG')

    # Windows's Command Prompt has poor support for ANSI escape sequences.
    puppet.options << '--color=false' if Vagrant::Util::Platform.windows?

    puppet.facter = {
      'hostname'               => mwv.boxname,
      'fqdn'                   => mwv.boxname + '.mediawiki-vagrant.dev',
      'git_user'               => settings[:git_user],
      'forwarded_port'         => settings[:http_port],
      'forwarded_https_port'   => settings[:https_port],
      'shared_apt_cache'       => '/vagrant/cache/apt/',
      'vmhost'                 => Socket.gethostname,
    }

    if settings[:http_port] != 80 && ENV['MWV_ENVIRONMENT'] != 'labs'
      puppet.facter['port_fragment'] = ":#{settings[:http_port]}"
    else
      puppet.facter['port_fragment'] = ''
    end

    if settings[:nfs_shares]
      puppet.facter['share_owner'] = Process.uid.to_s
      puppet.facter['share_group'] = Process.gid.to_s
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
# See 'support/Vagrantfile-extra.rb' for an example but make sure to follow
# the instructions in that file.  In particular it is important to copy it
# to the parent directory.  Editing it without copying it will only cause
# sadness.
begin
  require mwv.path('Vagrantfile-extra').to_s
rescue LoadError
end
