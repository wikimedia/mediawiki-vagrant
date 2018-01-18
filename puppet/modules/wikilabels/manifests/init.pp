# == Class: wikilabels
# This class installs the [wikilabels][https://meta.wikimedia.org/wiki/Wiki_labels] service,
# a manual scoring interface for ORES learning data.
#
# === Parameters
#
# [*deploy_dir*]
#   Path where Wikilabels should be installed (example: '/vagrant/srv/wikilabels').
#
# [*db_name*]
#   Logical PostgreSQL database name (example: 'wikilabels').
#
# [*db_user*]
#   PostgreSQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for PostgreSQL account (example: 'secret123').
#
# [*vhost_name*]
#   Hostname of the Wikilabels server (example: 'wikilabels.local.wmftest.net').
#
# [*port*]
#   Port used by the Wikilabels server (only visible inside the virtual machine).
#
class wikilabels (
    $deploy_dir,
    $db_name,
    $db_user,
    $db_pass,
    $vhost_name,
    $port,
) {
    include ::apache
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers

    require_package('postgresql', 'postgresql-server-dev-all', 'libffi-dev', 'g++', 'python3-dev', 'libmemcached-dev')

    # virtualize since it needs Python 3
    virtualenv::environment { $deploy_dir:
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        python  => 'python3',
        require => Package['postgresql-server-dev-all', 'libffi-dev', 'g++', 'python3-dev', 'libmemcached-dev'],
    }
    virtualenv::package { 'wikilabels':
        package  => 'git+https://github.com/wiki-ai/wikilabels.git#egg=wikilabels',
        path     => $deploy_dir,
        editable => true,
    }
    $repo_dir = "${deploy_dir}/src/wikilabels"

    $cfg_file = "${repo_dir}/config/999-vagrant.yaml"
    file { $cfg_file:
        ensure  => present,
        content => template('wikilabels/wikilabels.yaml.erb'),
        require => Virtualenv::Package['wikilabels'],
    }

    $db_script = "${deploy_dir}/bin/create_wikilabels_db.sh"
    file { $db_script:
        ensure  => present,
        content => template('wikilabels/create_wikilabels_db.sh.erb'),
        mode    => 'a+x',
        owner   => $::share_owner,
        group   => $::share_group,
        require => Virtualenv::Environment[$deploy_dir],
    }
    # psql does not like multiple commands as inline parameter. &&-ing them works but is a bit ugly.
    exec { 'create wikilabels database':
        command => "/bin/bash ${db_script}",
        unless  => "psql -lqt | cut -d \\| -f 1 | grep -qw ${db_name}",
        user    => 'postgres',
        require => [
          File[$db_script],
          Package['postgresql'],
          VirtualEnv::Package['wikilabels'],
        ],
    }
    exec { 'initialize wikilabels database':
        # puppet does not allow specifying separate users for command and unless so sudoing ensues
        command => "echo y | sudo -u www-data ${deploy_dir}/bin/wikilabels load_schema --reload-test-data",
        unless  => "sudo -u postgres psql -d ${db_name} -c \"SELECT 'campaign'::regclass\" >& /dev/null",
        cwd     => $repo_dir,
        require => [
          Exec['create wikilabels database'],
          Virtualenv::Package['wikilabels'],
          File[$cfg_file],
        ],
    }

    apache::reverse_proxy { 'wikilabels':
        port => $port,
    }

    systemd::service { 'wikilabels':
        ensure         => present,
        service_params => {
            require   => [
                VirtualEnv::Package['wikilabels'],
                Class['mediawiki::ready_service'],
                Exec['initialize wikilabels database'],
                Apache::Site['wikilabels'],
            ],
            subscribe => [
                File[$cfg_file],
            ],
        },
    }
}

