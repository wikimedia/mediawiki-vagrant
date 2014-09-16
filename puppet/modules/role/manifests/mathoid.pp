# == Class: role::mathoid
# This role installs the mathoid service for server side MathJax rendering.
#
class role::mathoid {
    require ::mathoid::install::git
}
