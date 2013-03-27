# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

    config.vm.hostname = 'mediawiki-vagrant'
    config.package.name = 'mediawiki.box'

    config.vm.box = 'precise-cloud'
    config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'

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

    config.vm.synced_folder 'mediawiki', '/var/www/w',
        owner: 'vagrant',
        group: 'www-data',
        extra: 'dmode=770,fmode=770',
        create: true

    config.vm.provider :virtualbox do |vb|
        # See http://www.virtualbox.org/manual/ch08.html for additional options.
        vb.customize ['modifyvm', :id, '--memory', '512', '--ostype', 'Ubuntu_64']
    end

    config.vm.provision :shell do |s|
        # Silence 'stdin: is not a tty' error on Puppet run
        s.inline = 'sed -i -e "s/^mesg n/tty -s \&\& mesg n/" /root/.profile'
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = 'puppet/modules'
        puppet.manifests_path = 'puppet/manifests'
        puppet.manifest_file = 'site.pp'
        puppet.options = '--verbose'  # Add '--debug' for more output
    end

end
