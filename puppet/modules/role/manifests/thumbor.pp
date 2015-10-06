# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    include ::role::varnish
    include ::thumbor
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers
    include ::role::statsd

    mediawiki::settings { 'thumbor-repo':
        values => template('role/thumbor/local_repo.php.erb'),
    }

    mediawiki::settings { 'thumbor':
        values => {
            'wgIgnoreImageErrors' => true,
        }
    }
}
