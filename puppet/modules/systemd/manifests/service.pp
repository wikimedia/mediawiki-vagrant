# == Define: systemd::service
#
# Allows defining a system service (e.g. Apache) and it's corresponding
# systemd init scripts. Expects a template to be found in
# "${caller_module_name}/systemd/${template_name}.erb".
#
# This is a simplifed version of base::service_unit from Wikimedia's
# operations/puppet.git Puppet configuration.
#
# === Parameters
# [*ensure*]
# Whether the systemd unit files should exist and if $declare_service is true
# whether the corresponding service should be running. Possible values:
# 'present', 'absent'. Default: 'present'.
#
# [*is_override*]
# Should the systemd unit be used as a site-specific override for a system
# provided unit or not. Default: false.
#
# [*refresh*]
# Should a change to the configuration file notify the service? Default: true.
#
# [*template_name*]
# Name of the systemd unit template. Default: $name.
#
# [*declare_service*]
# Should a Service resource be defined by this define or not? Default: true.
#
# [*service_params*]
# A hash of parameters to applied to the Service resource. Default: {}
#
# [*template_variables*]
# Variables to be exposed to the template. Default: {}
#
# [*epp_template*]
# Whether or not the service template is EPP rather than ERB. Default: false
#
define systemd::service (
    $ensure             = 'present',
    $is_override        = false,
    $refresh            = true,
    $template_name      = $name,
    $declare_service    = true,
    $service_params     = {},
    $template_variables = {},
    $epp_template       = false,
) {
    validate_ensure($ensure)
    $unit_template = $epp_template ? {
        true    => "${caller_module_name}/systemd/${template_name}.epp",
        default => "${caller_module_name}/systemd/${template_name}.erb",
    }

    $unit_path = $is_override ? {
        true    => "/etc/systemd/system/${name}.service.d/puppet-override.conf",
        default => "/lib/systemd/system/${name}.service",
    }

    if $is_override {
        file { "/etc/systemd/system/${name}.service.d":
            ensure => 'directory',
            owner  => 'root',
            group  => 'root',
            mode   => '0555',
            before => File[$unit_path],
        }
    }

    $unit_content = $epp_template ? {
        true    => epp($unit_template, $template_variables),
        default => template($unit_template),
    }
    file { $unit_path:
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => $unit_content,
    }

    exec { "systemd reload for ${name}":
        refreshonly => true,
        command     => '/bin/systemctl daemon-reload',
        subscribe   => File[$unit_path],
    }

    if $declare_service {
        if $refresh {
            # Notify service of changes to file
            File[$unit_path] ~> Service[$name]
        } else {
            # Ensure that file is applied before the service is called
            File[$unit_path] -> Service[$name]
        }

        # Ensure that systemd reloads before the service is called
        Exec["systemd reload for ${name}"] -> Service[$name]

        $enable = $ensure ? {
            'present' => true,
            default   => false,
        }
        $base_params = {
            ensure   => ensure_service($ensure),
            provider => 'systemd',
            enable   => $enable,
        }
        $params = merge($base_params, $service_params)
        ensure_resource('service', $name, $params)
    }
}
