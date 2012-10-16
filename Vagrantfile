# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

	config.vm.box = "precise32"
	config.vm.box_url = "http://files.vagrantup.com/precise32.box"

	# Boot with a GUI so you can see the screen. (Default is headless)
	# config.vm.boot_mode = :gui

	# Assign this VM to a host-only network IP, allowing you to access it
	# via the IP. Host-only networks can talk to the host machine as well as
	# any other machines on the same network, but cannot be accessed (through this
	# network interface) by any external networks.
	# config.vm.network :hostonly, "192.168.33.10"

	# Assign this VM to a bridged network, allowing you to connect directly to a
	# network using the host's network device. This makes the VM appear as another
	# physical device on your network.
	config.vm.network :bridged

	# Forward a port from the guest to the host, which allows for outside
	# computers to access the VM, whereas host only networking does not.
	config.vm.forward_port 80, 8080

	# Share an additional folder to the guest VM. The first argument is
	# an identifier, the second is the path on the guest to mount the
	# folder, and the third is the path on the host to the actual folder.
	config.vm.share_folder "mediawiki", "/srv/mediawiki", "mediawiki"

	Vagrant::Config.run do |config|
		config.vm.provision :puppet do |puppet|
			puppet.manifests_path = "manifests"
			puppet.manifest_file = "base.pp"
		end
	end

end
