# vim:set sw=4 ts=4 sts=4 et:

# == Define: vagrant::settings
#
# Provision a yaml settings file that will be read by the Vagrantfile managing
# the VM.
#
#
# === Parameters
#
# [*priority*]
#   This parameter takes a numeric value, which is used to generate a
#   prefix for the configuration snippet. Settings managed by Puppet will
#   load in order of priority, with smaller values loading first. The
#   default is 10. You only need to override the default if you want
#   these settings to load before or after some other settings.
#
# [*box_name*]
#   Name of the Vagrant box to load on the VM.
#
# [*box_uri*]
#   Download URL for the vagrant box.
#
# [*ram*]
#   Amount of RAM to allocate to the virtual machine in MB.
#
# [*cores*]
#   Number of virtual CPUs to allocate to virtual machine.
#
# [*static_ip*]
#   Static IP address for virtual machine.
#
# [*http_port*]
#   The port on the host machine that should be forwared to the virtual
#   machine's HTTP server (port 80).
#
# [*forward_ports*]
#   Hash of virtual machine port to host machine port pairs for Vagrant to
#   forward.
#
# [*puppet_debug*]
#   Run puppet in debug mode.
#
# === Example
#
# Configure an Ubuntu 14.04 instance with a lot of ram and cpu and
# port forwarding for Elasticsearch development:
#
#   vagrant::settings { 'big trusty instance':
#     box_name      => 'trusty-cloud',
#     box_uri       => 'http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box',
#     ram           => 4096,
#     cores         => 4,
#     forward_ports => { 9200 => 9200 },
#   }
#
define vagrant::settings(
    $ensure        = present,
    $priority      = 10,
    $box_name      = undef,
    $box_uri       = undef,
    $ram           = undef,
    $cores         = undef,
    $static_ip     = undef,
    $http_port     = undef,
    $forward_ports = undef,
    $puppet_debug  = undef,
) {
    include ::vagrant

    # make a safe filename based on our title
    $fname = inline_template('<%= @title.gsub(/\W/, "-") %>')
    $settings_file = sprintf('%s/%.2d-%s.yaml',
        $::vagrant::settings_dir, $priority, $fname)

    file { $settings_file:
        ensure  => $ensure,
        content => template('vagrant/settings.yaml.erb'),
        group   => 'www-data',
        owner   => 'vagrant',
        notify  => Shout[$settings_file],
    }

    shout { $settings_file:
      message => 'Vagrant settings have been changed.
        Run `vagrant reload` to apply the changes.',
    }
}
