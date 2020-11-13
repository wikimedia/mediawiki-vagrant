# == Class: role::abusefilter
# Installs the AbuseFilter[https://www.mediawiki.org/wiki/Extension:AbuseFilter]
# extension which allows privileged users to set specific controls
# on actions by users, such as edits, and create automated reactions
# for certain behaviors.
#
class role::abusefilter {
    mediawiki::extension { 'AbuseFilter':
        settings     => template('role/abusefilter/settings.php.erb'),
        needs_update => true,
    }
}

