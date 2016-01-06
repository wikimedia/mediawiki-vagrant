# == Class: role::variables
# The Variables extension allows you to define a variable on a page, use it
# later in that same page or included templates, change its value, possibly to
# a value given by an expression in terms of the old value, etc.
class role::variables {

    require ::role::mediawiki

    mediawiki::extension { 'Variables': }
}
