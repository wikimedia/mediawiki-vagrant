# Based on operations/puppet at 504a37a, with changes
# == Class: mediawiki::mwrepl
#
# 'mwrepl' is a command line REPL, read-eval-print-loop, utility. This
# module ensures that mwrepl is installed
#
# == Parameters:
#
# [*default_db_name*]
#   MediaWiki default DB name
#
# [*script_dir*]
#   MediaWiki script directory
class mediawiki::mwrepl(
    $default_db_name,
    $script_dir,
) {
    file { '/usr/local/bin/mwrepl':
        content => template('mediawiki/mwrepl/mwrepl.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
    }
}
