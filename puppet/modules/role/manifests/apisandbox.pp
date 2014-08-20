# == Class: role::apisandbox
# This role simply sets up the ApiSandbox extension
class role::apisandbox {
    mediawiki::extension { 'ApiSandbox': }
}
