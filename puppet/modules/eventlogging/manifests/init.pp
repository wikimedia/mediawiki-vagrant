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

    require_package('default-libmysqlclient-dev')
    require_package('librdkafka-dev')

    # Do the initial pip install into the virtualenv
    exec { 'eventlogging_virtualenv_pip_install':
        command => "${path}/virtualenv/bin/pip install --no-binary mysqlclient -e .",
        cwd     => $path,
        creates => "${path}/virtualenv/local/lib/python2.7/site-packages/eventlogging.egg-link",
        require => [
            Service::Gitupdate['eventlogging'],
            Package['default-libmysqlclient-dev'],
            Package['librdkafka-dev']
        ],
    }
}
