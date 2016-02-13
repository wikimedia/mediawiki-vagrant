# == Class: role::abusefilter
# Installs the [AbuseFilter][1] extension which allows privileged
# users to set specific controls on actions by users, such as
# edits, and create automated reactions for certain behaviors.
#
# [1] https://www.mediawiki.org/wiki/Extension:AbuseFilter
#
class role::abusefilter {
    mediawiki::extension { 'AbuseFilter':
        settings     => template('role/abusefilter/settings.php.erb'),
        needs_update => true,
    }
}

