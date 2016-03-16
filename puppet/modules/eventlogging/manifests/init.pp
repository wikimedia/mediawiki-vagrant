# == Class eventlogging
#
class eventlogging {
    require ::service

    $path = "${::service::root_dir}/eventlogging"

    git::clone { 'eventlogging':
        directory => $path,
    }

    service::gitupdate { 'eventlogging':
        type    => 'python',
        update  => true,
        require => Git::Clone['eventlogging'],
    }

    require_package('libmysqlclient-dev')

    # These packages aren't currently satisfied by eventlogging's
    # setup.py due to Trusty vs. Jessie issues.  This will
    # be remedied when WMF eventlogging production deployment is fixed.
    # See: https://github.com/wikimedia/eventlogging/blob/master/setup.py#L60
    Virtualenv::Package {
        path => "${path}/virtualenv",
        require => Service::Gitupdate['eventlogging'],
    }

    virtualenv::package { 'etcd': }
    virtualenv::package { 'tornado': }
    virtualenv::package { 'sprockets.mixins.statsd': }
    # mysqlclient pip package installs a python module called MySQLdb.
    virtualenv::package { 'mysqlclient':
        python_module => 'MySQLdb',
        require       => Package['libmysqlclient-dev'],
    }

    # Do the initial pip install into the virtualenv
    exec { 'eventlogging_virtualenv_pip_install':
        command => "${path}/virtualenv/bin/pip install .",
        cwd     => $path,
        creates => "${path}/virtualenv/local/lib/python2.7/site-packages/eventlogging",
        require => [
            Service::Gitupdate['eventlogging'],
            Virtualenv::Package['etcd'],
            Virtualenv::Package['tornado'],
            Virtualenv::Package['sprockets.mixins.statsd'],
            Virtualenv::Package['mysqlclient'],
        ],
    }
}
