# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'rbconfig'

# Check if we're running on Windows.
def windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
end

# Get VirtualBox's version string by capturing the output of 'VBoxManage -v'.
# Returns empty string if unable to determine version.
def get_virtualbox_version
    begin
        if windows?
            ver = `"%ProgramFiles%\\Oracle\\VirtualBox\\VBoxManage" -v 2>NULL`
        else
            ver = `VBoxManage -v 2>/dev/null`
        end
    rescue
        ver = ''
    end
    ver.gsub(/r.*/m, '')
end

Vagrant.configure('2') do |config|

    config.vm.hostname = 'mediawiki-vagrant'
    config.package.name = 'mediawiki.box'

    # Note: If you rely on Vagrant to retrieve the box, it will not
    # verify SSL certificates. If this concerns you, you can retrieve
    # the file using another tool that implements SSL properly, and then
    # point Vagrant to the downloaded file:
    #   $ vagrant box add precise-cloud /path/to/file/precise.box
    config.vm.box = 'precise-cloud'
    config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

    config.vm.network :private_network,
        ip: '10.11.12.13'

    config.vm.network :forwarded_port,
        guest: 80,
        host: 8080,
        id: 'http',
        auto_correct: true

    config.vm.synced_folder '.', '/vagrant',
        owner: 'vagrant',
        group: 'www-data',
        extra: 'dmode=770,fmode=770'

    config.vm.provider :virtualbox do |vb|
        # See http://www.virtualbox.org/manual/ch08.html for additional options.
        vb.customize ['modifyvm', :id, '--memory', '512']
        vb.customize ['modifyvm', :id, '--ostype', 'Ubuntu_64']

        # If you are on a single-core system, comment out the following line:
        vb.customize ["modifyvm", :id, '--cpus', '2']
    end

    config.vm.provision :shell do |s|
        # Silence 'stdin: is not a tty' error on Puppet run
        s.inline = 'sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile'
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = 'puppet/modules'
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'
        puppet.options = '--verbose'

        # For more output, uncomment the following line:
        # puppet.options << ' --debug'

        # Windows's Command Prompt has poor support for ANSI escape sequences.
        puppet.options << ' --color=false' if windows?

        puppet.facter = {
            'virtualbox_version' => get_virtualbox_version
        }
    end

end
