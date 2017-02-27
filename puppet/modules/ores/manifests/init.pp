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

    # ORES (in a venv as it needs Python 3)
    virtualenv::environment { $deploy_dir:
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        python  => 'python3',
        require => Package['python3-dev', 'g++', 'gfortran', 'liblapack-dev', 'libopenblas-dev', 'libenchant-dev'],
    }
    virtualenv::package { 'ores':
        package  => 'git+https://github.com/wiki-ai/ores.git#egg=ores',
        path     => $deploy_dir,
        editable => true,
    }
    #FIXME this should happen as part of normal dependency management but for some reason it doesn't
    # pylru probably needs to be fixed in the revscoring pakcage, redis in ores
    exec { 'pip_install_revscoring_dependencies_hack':
        command => "curl https://raw.githubusercontent.com/wiki-ai/revscoring/master/requirements.txt | ${deploy_dir}/bin/pip install pylru redis -r /dev/stdin",
        cwd     => $deploy_dir,
        require => Virtualenv::Package['ores'],
    }
    $repo_dir = "${deploy_dir}/src/ores"

    apache::site { 'ores':
        ensure  => present,
        content => template('ores/apache-site-ores.erb'),
        require => [
          Class['::apache::mod::proxy'],
          Class['::apache::mod::proxy_http'],
          Class['::apache::mod::headers'],
        ],
    }

    $cfg_file = "${repo_dir}/config/999-vagrant.yaml"
    file { $cfg_file:
        ensure  => present,
        content => template('ores/ores.yaml.erb'),
        require => Virtualenv::Package['ores'],
    }

    systemd::service { 'ores-wsgi':
        ensure         => present,
        service_params => {
            require   => [
                VirtualEnv::Package['wikilabels'],
                Exec['pip_install_revscoring_dependencies_hack'],
                Apache::Site['wikilabels'],
            ],
            subscribe => [
                File[$cfg_file],
            ],
        },
    }
    systemd::service { 'ores-celery':
        ensure         => present,
        service_params => {
            require   => [
                VirtualEnv::Package['ores'],
                Exec['pip_install_revscoring_dependencies_hack'],
                Apache::Site['ores'],
            ],
            subscribe => [
                File[$cfg_file],
            ],
        },
    }
}

