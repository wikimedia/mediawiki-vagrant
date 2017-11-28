# == Class: ores
# This role installs the [ORES][https://ores.wikimedia.org/] service.
#
# === Parameters
#
# [*deploy_dir*]
#   Path where ORES should be installed (example: '/vagrant/srv/ores').
#
# [*vhost_name*]
#   Hostname of the ORES server (example: 'ores.local.wmftest.net').
#
# [*port*]
#   Port used by the ORES server (only visible inside the virtual machine).
#
class ores (
    $deploy_dir,
    $vhost_name,
    $port,
) {
    include ::apache
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers
    require ::virtualenv

    # revscoring
    require_package('python3-dev', 'g++', 'gfortran', 'liblapack-dev', 'libopenblas-dev', 'libenchant-dev')

    file { $deploy_dir:
        ensure => directory,
    }

    # ORES (in a venv as it needs Python 3)
    $venv_dir = "${deploy_dir}/venv"
    virtualenv::environment { $venv_dir:
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        python  => 'python3',
        require => [
            Package['python3-dev', 'g++', 'gfortran', 'liblapack-dev', 'libopenblas-dev', 'libenchant-dev'],
            File[$deploy_dir],
        ],
    }

    $sources_dir = "${deploy_dir}/src"
    file { $sources_dir:
        ensure => directory,
    }
    git::clone { 'revscoring':
        directory => "${sources_dir}/revscoring",
        remote    => 'https://github.com/wiki-ai/revscoring',
        require   => File[$sources_dir],
    }
    $ores_root = "${sources_dir}/ores"
    git::clone { 'ores':
        directory => $ores_root,
        remote    => 'https://github.com/wiki-ai/ores',
        require   => File[$sources_dir],
    }

    virtualenv::package { 'revscoring':
        package  => "${sources_dir}/revscoring",
        path     => $venv_dir,
        editable => true,
        require  => Git::Clone['revscoring'],
    }

    virtualenv::package { 'ores':
        # Tricky syntax to get pip to install ores with the extra "redis"
        # dependencies specified in setup.py
        package  => "${ores_root}[redis]",
        path     => $venv_dir,
        editable => true,
        require  => [
            Virtualenv::Package['revscoring'],
            Git::Clone['ores'],
        ],
    }

    apache::reverse_proxy { 'ores':
        port => $port,
    }

    $cfg_file = "${ores_root}/config/999-vagrant.yaml"
    file { $cfg_file:
        ensure  => present,
        content => template('ores/ores.yaml.erb'),
        require => Git::Clone['ores'],
    }

    $logging_config = "${ores_root}/logging_config.yaml"
    file { $logging_config:
        ensure  => present,
        content => template('ores/logging.yaml.erb'),
        require => Virtualenv::Package['ores'],
    }

    systemd::service { 'ores-wsgi':
        ensure         => present,
        service_params => {
            require   => [
                Virtualenv::Package['ores'],
                Class['mediawiki::ready_service'],
                Apache::Site['ores'],
            ],
            subscribe => [
                File[$cfg_file],
                File[$logging_config],
            ],
        },
    }
    systemd::service { 'ores-celery':
        ensure         => present,
        service_params => {
            require   => [
                Virtualenv::Package['ores'],
                Class['mediawiki::ready_service'],
                Apache::Site['ores'],
            ],
            subscribe => [
                File[$cfg_file],
                File[$logging_config],
            ],
        },
    }
}

