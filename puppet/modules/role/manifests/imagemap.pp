# == Class: role::imagemap
# ImageMap is extension which allows clickable image maps.
#
class role::imagemap {
    include ::role::mediawiki
    mediawiki::extension { 'ImageMap': }
}