# Imports an xml dump into the wiki.
#
#  $xml_dump should be the /fully/qualified/path to a dump
#
#  $dump_sentinel_page should specify a page unique to the dump.  As long as
#   $dump_sentinel_page is not present in the wiki we will keep trying the import.
#
# We try to do this only on the first run and not clobber existing imports.
#
define mediawiki::import_dump(
    $xml_dump,
    $dump_sentinel_page,
) {
    include mediawiki

    exec { 'import_dump':
        require   => Class['mediawiki'],
        cwd       => "${mediawiki::dir}/maintenance",
        command   => "/usr/bin/php5 importDump.php ${xml_dump}",
        unless    => "/usr/bin/php5 pageExists.php ${dump_sentinel_page}",
        user      => 'www-data',
        logoutput => on_failure,
    }
}
