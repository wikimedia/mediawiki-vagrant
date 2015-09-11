# == Class: role::scholarships
# Provisions the Wikimania Scholarships application.
#
# *Note*: The application is provisioned using an Apache named virtual host.
# Once the role is enabled and provisioned use the URL
# http://scholarships.local.wmftest.net:8080/ to access the site.
class role::scholarships {
    include ::scholarships
}
