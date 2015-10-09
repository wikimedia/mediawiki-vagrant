# == Class: role::mobilecontentservice
# This role installs the mobile content service.
#
class role::mobilecontentservice {
    include ::role::restbase
    include ::mobilecontentservice
}
