# == Class: role::globalusage
# This role provisions the [GlobalUsage][1] extension.
#
# You need to execute the following command to get usage
# information for existing files:
#
#     php extensions/GlobalUsage/refreshGlobalimagelinks.php
#
# This will throw an error, but seems to work nevertheless.
#
# [1] https://www.mediawiki.org/wiki/Extension:GlobalUsage
class role::globalusage {
    mediawiki::extension { 'GlobalUsage':
        needs_update => true,
    }
}
