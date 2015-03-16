# == Class: role::phabricator
# Phabricator is an open source collection of web applications which help
# software companies build better software.
#
# *Note*: The application is provisioned using an Apache named virtual host.
# Once the role is enabled and provisioned use the URL
# http://phabricator.local.wmftest.net:8080/ to access the site.
class role::phabricator {
    include ::phabricator
}
