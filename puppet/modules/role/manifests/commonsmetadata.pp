# == Class: role::commonsmetadata
# This role provisions the CommonsMetadata[https://www.mediawiki.org/wiki/Extension:CommonsMetadata] extension,
# which adds image metadata extracted from the
# description page to the imageinfo API.
class role::commonsmetadata {
    include ::role::multimedia

    mediawiki::extension { 'CommonsMetadata': }
}
