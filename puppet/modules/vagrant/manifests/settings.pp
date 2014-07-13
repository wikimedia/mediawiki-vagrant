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
# === Example
#
# Configure an instance with a lot of ram and cpu and port forwarding for
# Elasticsearch development:
#
#   vagrant::settings { 'big elasticsearch':
#     ram           => 4096,
#     cores         => 4,
#     forward_ports => { 9200 => 9200 },
#   }
#
define vagrant::settings(
    $ensure        = present,
    $priority      = 10,
    $ram           = undef,
    $cores         = undef,
    $static_ip     = undef,
    $http_port     = undef,
    $forward_ports = undef,
) {
    include ::vagrant

    # make a safe filename based on our title
    $fname = inline_template('<%= @title.gsub(/\W/, "-") %>')
    $settings_file = sprintf('%s/%.2d-%s.yaml',
        $::vagrant::settings_dir, $priority, $fname)

    file { $settings_file:
        ensure  => $ensure,
        content => template('vagrant/settings.yaml.erb'),
        owner   => $::share_owner,
        group   => $::share_group,
    }

    exec { "${fname} wants reload":
        command     => "/usr/bin/touch ${::vagrant::settings_dir}/RELOAD",
        refreshonly => true,
        creates     => "${::vagrant::settings_dir}/RELOAD",
        subscribe   => File[$settings_file],
    }
}
