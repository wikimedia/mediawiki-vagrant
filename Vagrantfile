# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

	config.vm.box = "precise32"
	config.vm.box_url = "http://files.vagrantup.com/precise32.box"

	# Boot with a GUI so you can see the screen. (Default is headless)
	# config.vm.boot_mode = :gui

	# Assign this VM to a bridged network, allowing you to connect directly to a
	# network using the host's network device. This makes the VM appear as another
	# physical device on your network.
	config.vm.network :bridged

	# Forward tcp://host:8080 => tcp://guest:80
	config.vm.forward_port 80, 8080

	# Mount working folder as "/vagrant" in guest VM.
	config.vm.share_folder "vagrant", "/srv", "."

	# To enable NFS, see: http://vagrantup.com/v1/docs/nfs.html
	# NFS improves the performance of file sharing considerably,
	# but requires admin rights to install on OS X.

	config.vm.provision :puppet do |puppet|
		puppet.options = ["--verbose", "--debug"]
		puppet.manifest_file = "base.pp"
		puppet.manifests_path = "manifests"
		puppet.module_path = "modules"
	end

end
