# == Class: role::jade
#
# Set up the JADE API server and MediaWiki extension.
# See the ::jade module for more information.
#
class role::jade {
    require ::jade

    include ::role::eventbus
}
