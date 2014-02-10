# == Class: role::commonsmetadata
# This role provisions the CommonsMetadata extension,
# which adds image metadata extracted from the
# description page to the imageinfo API.
class role::commonsmetadata {
    include role::mediawiki
    include role::multimedia

    mediawiki::extension { 'CommonsMetadata': }
}
