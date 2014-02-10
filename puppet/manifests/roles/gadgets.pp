# == Class: role::gadgets
# The Gadgets extension provides a way for users to pick JavaScript
# or CSS based "gadgets" that other wiki users provide.
class role::gadgets {
    mediawiki::extension { 'Gadgets': }
}
