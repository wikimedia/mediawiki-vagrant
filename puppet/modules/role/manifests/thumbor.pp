# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    require ::mediawiki
    include ::thumbor
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers

    $images_dir = "${::mwv::files_dir}/images"
    $server_url = $::mediawiki::server_url

    apache::site_conf { 'Proxy thumbnail requests to thumbor for JPG and PNG':
        site    => $::mediawiki::wiki_name,
        content => template('role/thumbor/apache2.conf.erb'),
    }
}

