# == Class: role::pipeescape
# The PipeEscape extension allows for pipe characters in parser function
# arguments (and template argument calls) avoid being interpreted as an
# argument delimiter. This is primarily for the purpose of using wiki tables
# (or parts thereof) inside parser function calls or templates.
class role::pipeescape {

    require ::role::mediawiki

    mediawiki::extension { 'PipeEscape': }
}
