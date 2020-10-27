# == Class: role::addlink
# Sets up the Add Link pipeline.
# See https://wikitech.wikimedia.org/wiki/Add_Link
#
# === Parameters
#
# [*db_name*]
#   Logical MySQL database name (example: 'addlink').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'addlink_user').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*service_dir*]
#   Path where mwaddlink should be installed (example: '/srv/mwaddlink').
#
# [*service_port*]
#   Port which the service listens on (example: 8000).
#
class role::addlink (
    $db_name,
    $db_user,
    $db_pass,
    $service_dir,
    $service_port,
) {
    require ::mysql
    require ::virtualenv
    require ::mwv

    include ::role::growthexperiments

    $venv_dir = "${service_dir}/.venv"
    git::clone { 'research/mwaddlink':
        directory => $service_dir,
        branch    => 'main',
    }
    virtualenv::environment { $venv_dir:
        owner   => $::share_owner,
        group   => $::share_group,
        python  => 'python3.7',
        require => Git::Clone['research/mwaddlink'],
    }
    virtualenv::package { 'mwaddlink':
        path          => $venv_dir,
        package       => "-r ${service_dir}/requirements-query.txt",
        python_module => 'mwparserfromhell',
    }
    service::gitupdate { 'mwaddlink':
        dir            => $service_dir,
        virtualenv_dir => $venv_dir,
        type           => 'python',
        update         => true,
        restart        => true,
    }

    file { "${venv_dir}/bin/download-punkt.py":
        content => template('role/addlink/download-punkt.py.erb'),
        owner   => 'vagrant',
        mode    => 'o+rx',
        require => Virtualenv::Environment[$venv_dir],
    }
    exec { 'nltk-punkt':
        command => "${venv_dir}/bin/python ${venv_dir}/bin/download-punkt.py",
        user    => 'vagrant',
        creates => '/home/vagrant/nltk_data',
        require => [
            File["${venv_dir}/bin/download-punkt.py"],
            Virtualenv::Package['mwaddlink'],
        ],
    }

    mysql::db { $db_name:
        ensure => present,
    }
    mysql::user { $db_user:
        ensure   => present,
        grant    => "ALL ON ${db_name}.*",
        password => $db_pass,
        require  => Mysql::Db[$db_name],
    }

    systemd::service { 'mwaddlink':
        ensure             => 'present',
        service_params     => {
            require   => [
                Virtualenv::Package['mwaddlink'],
                Mysql::User[$db_user],
                Exec['nltk-punkt'],
            ],
        },
        epp_template       => true,
        template_variables => {
            db_name      => $db_name,
            db_user      => $db_user,
            db_pass      => $db_pass,
            service_dir  => $service_dir,
            venv_dir     => $venv_dir,
            service_port => $service_port,
        },
        template_dir       => 'role/addlink/systemd',
    }

    $service_url = "http://mwaddlink${::mwv::tld}${::port_fragment}/"
    apache::reverse_proxy { 'mwaddlink':
        port => $service_port,
    }
    mediawiki::settings { 'GrowthExperiments-Mwaddlink':
        values => {
            'wgGELinkRecommendationServiceUrl' => $service_url,
        },
    }
    mediawiki::import::text { 'VagrantRoleAddLink':
        content => template('role/addlink/VagrantRoleAddLink.wiki.erb'),
    }
}

