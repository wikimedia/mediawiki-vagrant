# == Class: role::widgets
# The Widgets extension allows the creation of raw HTML pages that can be
# embedded (similarly to templates) in normal wiki pages.
class role::widgets {

    require ::role::mediawiki

    mediawiki::extension { 'Widgets': }
}
