# == Class: role::commonsmetadata
# This role provisions the CommonsMetadata[1] extension,
# which adds image metadata extracted from the
# description page to the imageinfo API.
#
# [1] https://www.mediawiki.org/wiki/Extension:CommonsMetadata
class role::commonsmetadata {
    include role::mediawiki
    include role::multimedia

    mediawiki::extension { 'CommonsMetadata': }
}
