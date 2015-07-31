# == Class: role::wikimediaincubator
# The WikimediaIncubator extension adds support for workflows specific
# to Wikimedia Incubator (https://incubator.wikimedia.org).
class role::wikimediaincubator {
    mediawiki::extension { 'WikimediaIncubator': }
}
