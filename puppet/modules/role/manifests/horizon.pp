# == Class: role::horizon
#
# Provision an OpenStack horizon service accessible on the
# horizon.local.wmftest.net vhost.
#
# [*log_dir*]
#   Directory to write log files to. Directory must already exist.
#   A 'horizon' subdirectory will be created.
#
# [*vhost_name*]
#   Apache vhost name. (example: 'striker.local.wmftest.net')
class role::horizon (
    $log_dir,
    $vhost_name,
) {
    include ::role::keystone
    include ::apache
    include ::apache::mod::uwsgi
    include ::apache::mod::headers
    include ::apache::mod::proxy
    include ::apache::mod::proxy_balancer
    include ::apache::mod::proxy_http

    $deploy_dir = '/usr/share/openstack-dashboard/openstack_dashboard'
    $static_dir = '/var/lib/openstack-dashboard/static'

    $packages = [
      'fonts-font-awesome',
      'fonts-materialdesignicons-webfont',
      'fonts-roboto-fontface',
      'libjs-angular-gettext',
      'libjs-angularjs',
      'libjs-angularjs-smart-table',
      'libjs-bootswatch',
      'libjs-d3',
      'libjs-jquery-cookie',
      'libjs-jquery-metadata',
      'libjs-jquery-tablesorter',
      'libjs-jquery-ui',
      'libjs-jquery.quicksearch',
      'libjs-jsencrypt',
      'libjs-lrdragndrop',
      'libjs-magic-search',
      'libjs-rickshaw',
      'libjs-spin.js',
      'libjs-term.js',
      'libjs-twitter-bootstrap',
      'libjs-twitter-bootstrap-datepicker',
      'openstack-dashboard',
      'python-ceilometerclient',
      'python-compressor',
      'python-csscompressor',
      'python-designate-dashboard',
      'python-django',
      'python-django-appconf',
      'python-django-babel',
      'python-django-common',
      'python-django-compressor',
      'python-django-horizon',
      'python-django-openstack-auth',
      'python-django-overextends',
      'python-django-pyscss',
      'python-heatclient',
      'python-keystoneclient',
      'python-openstack-auth',
      'python-pint',
      'python-pyscss',
      'python-rcssmin',
      'python-rjsmin',
      'python-xstatic',
      'python-xstatic-angular',
      'python-xstatic-angular-bootstrap',
      'python-xstatic-angular-gettext',
      'python-xstatic-angular-lrdragndrop',
      'python-xstatic-bootstrap-datepicker',
      'python-xstatic-bootstrap-scss',
      'python-xstatic-bootswatch',
      'python-xstatic-d3',
      'python-xstatic-font-awesome',
      'python-xstatic-hogan',
      'python-xstatic-jasmine',
      'python-xstatic-jquery',
      'python-xstatic-jquery-migrate',
      'python-xstatic-jquery-ui',
      'python-xstatic-jquery.quicksearch',
      'python-xstatic-jquery.tablesorter',
      'python-xstatic-jsencrypt',
      'python-xstatic-magic-search',
      'python-xstatic-mdi',
      'python-xstatic-rickshaw',
      'python-xstatic-roboto-fontface',
      'python-xstatic-smart-table',
      'python-xstatic-spin',
      'python-xstatic-term.js',
    ]

    package { $packages:
        ensure  => 'present',
    }

    file { "${log_dir}/horizon":
        ensure => 'directory',
        mode   => '0777',
    }

    file { '/etc/openstack-dashboard/local_settings.py':
        ensure  => 'present',
        content => template('role/horizon/local_settings.py.erb'),
        owner   => 'www-data',
        group   => 'www-data',
        mode    => '0440',
        require => Package['openstack-dashboard'],
        notify  => [
            Systemd::Service['uwsgi-horizon'],
            Exec['djangorefresh'],
        ],
    }

    $port = 8081
    uwsgi::app { 'horizon':
        settings => {
            uwsgi => {
                plugins     => 'python, logfile',
                master      => true,
                http-socket => "127.0.0.1:${port}",
                processes   => 2,
                threads     => 2,
                die-on-term => true,
                chdir       => '/etc/openstack-dashboard',
                wsgi-file   => "${deploy_dir}/wsgi/django.wsgi",
                uid         => 'www-data',
                gid         => 'www-data',
                logger      => "file:${log_dir}/horizon/main.log",
                req-logger  => "file:${log_dir}/horizon/access.log",
                log-format  => '%(addr) - %(user) [%(ltime)] "%(method) %(uri) (proto)" %(status) %(size) "%(referer)" "%(uagent)" %(micros)',
            },
        },
    }

    apache::site { $vhost_name:
        ensure   => present,
        # Load before MediaWiki wildcard vhost for Labs.
        priority => 40,
        content  => template('role/horizon/apache.conf.erb'),
        require  => Uwsgi::App['horizon'],
        notify   => Service['apache2'],
    }

    exec { 'djangorefresh':
        refreshonly => true,
        command     => 'python manage.py collectstatic --noinput && python manage.py compress',
        path        => '/usr/bin',
        cwd         => '/usr/share/openstack-dashboard',
        require     => File['/etc/openstack-dashboard/local_settings.py'],
        notify      => Systemd::Service['uwsgi-horizon'],
    }
}
