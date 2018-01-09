# == Class: role::scholarships
# Provisions the Wikimania Scholarships application.
#
# *Note*: The application is provisioned using an Apache named virtual host.
# Once the role is enabled and provisioned use the URL
# http://scholarships.local.wmftest.net:8080/ to access the site.
class role::scholarships (
    $oauth_consumer_key,
    $oauth_secret_key,
) {
    include ::mediawiki
    include ::scholarships

    role::oauth::consumer { 'Wikimania Scholarships':
        description  => 'Wikimania Scholarships',
        consumer_key => $oauth_consumer_key,
        secret_key   => $oauth_secret_key,
        callback_url => "http://${::scholarships::vhost_name}${::port_fragment}/",
        grants       => ['authonlyprivate'],
    }
}
