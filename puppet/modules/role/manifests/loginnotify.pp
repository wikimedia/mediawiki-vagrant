# == Class: role::loginnotify
class role::loginnotify {
    include ::role::echo
    mediawiki::extension { 'LoginNotify': }
}
