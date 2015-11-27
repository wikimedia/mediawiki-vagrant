# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    require ::role::varnish
    require ::role::statsd
    require ::role::memcached
    require ::role::sentry
    require ::role::swift
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers
    include ::thumbor

    mediawiki::settings { 'thumbor-repo':
        values   => template('role/thumbor/local_repo.php.erb'),
        # Needs to be higher priority that swift for the local repo override
        priority => 20,
    }

    mediawiki::settings { 'thumbor':
        values => {
            'wgIgnoreImageErrors' => true,
        },
    }
}
