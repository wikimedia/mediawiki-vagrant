# == Class: hhvm::fcgi
#
# Provision a service to run HHVM in FCGI mode serving MediaWiki
#
class hhvm::fcgi {
    require ::hhvm
    require ::mediawiki::ready_service

    systemd::service { 'hhvm':
        ensure         => 'present',
        is_override    => true,
        service_params => {
            subscribe => [
                Package['hhvm'],
                Package[$::hhvm::ext_pkgs],
                File['/etc/hhvm/server.ini'],
                File['/etc/default/hhvm'],
            ],
        },
    }
}

