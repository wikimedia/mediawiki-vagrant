# == Class: crm::dash
#
# Fundraising dashboard
#
class crm::dash (
) {
    require ::npm

    # FIXME this should be in hieradata
    $fundraising_dash_dir = '/vagrant/srv/fundraising-dash'

    git::clone { 'wikimedia/fundraising/dash':
        directory => $fundraising_dash_dir
    }

    npm::install { 'dash_npm_install':
        directory => $fundraising_dash_dir,
        require   => Git::Clone['wikimedia/fundraising/dash']
    }

    exec { 'dash_bower_install':
        command     => "${fundraising_dash_dir}/node_modules/bower/bin/bower install",
        cwd         => $fundraising_dash_dir,
        require     => Npm::Install['dash_npm_install'],
        user        => 'vagrant',
        environment => 'HOME=/home/vagrant'
    }

    file { 'dash_settings_js':
        path    => "${fundraising_dash_dir}/settings.js",
        content => template('crm/dash.js.erb'),
        mode    => '0644',
        require => Exec['dash_bower_install'],
    }

    exec { 'dash_schema':
        command => "cat ${fundraising_dash_dir}/schema/*.sql | /usr/bin/mysql -u root -p${mysql::root_password} fredge -qfsA",
        require => [
            File['dash_settings_js'],
            Mysql::Db['fredge'],
        ],
    }

    file { '/etc/init/fundraising_dash.conf':
        content => template('crm/fundraising_dash.conf.erb'),
    }

    systemd::service { 'fundraising_dash':
      ensure  => present,
      require => Exec['dash_schema'],
    }

}
