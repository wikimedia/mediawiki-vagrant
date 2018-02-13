# == Class: crm::dash
#
# Fundraising dashboard
#
class crm::dash (
    $dir,
) {
    require ::npm

    git::clone { 'wikimedia/fundraising/dash':
        directory => $dir
    }

    npm::install { 'dash_npm_install':
        directory => $dir,
        require   => Git::Clone['wikimedia/fundraising/dash']
    }

    exec { 'dash_bower_install':
        command     => "${dir}/node_modules/bower/bin/bower install",
        cwd         => $dir,
        require     => Npm::Install['dash_npm_install'],
        user        => 'vagrant',
        environment => 'HOME=/home/vagrant'
    }

    file { 'dash_settings_js':
        path    => "${dir}/settings.js",
        content => template('crm/dash.js.erb'),
        mode    => '0644',
        require => Exec['dash_bower_install'],
    }

    exec { 'dash_schema':
        command => "cat ${dir}/schema/*.sql | /usr/bin/mysql fredge -qfsA",
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