# == Class: role::apparmor
#
# Basic apparmor configuration. AppArmor is a Linux Security Module
# implementation of name-based access controls. AppArmor confines individual
# programs to a set of listed files and posix 1003.1e draft capabilities.
class role::apparmor {
    include ::apparmor
}
