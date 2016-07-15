# == Class: role::iegreview
# Provisions the IEG grant review application.
#
# *Note*: The application is provisioned using an Apache named virtual host.
# Once the role is enabled and provisioned use the URL
# http://iegreview.local.wmftest.net:8080/ to access the site.
class role::iegreview {
    include ::parsoid
    include ::iegreview
}
