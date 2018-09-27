# == Class: role::dumps
# Backup dumps infrastructure.
class role::dumps {
    include ::role::mediawiki
    include ::mwv

    $site_name = "dumps${::mwv::tld}"

    $dumps_dir = "${::mwv::services_dir}/dumps"

    $conf_dir = "${dumps_dir}/confs"
    $dblists_dir = "${dumps_dir}/dblists"
    $mediawiki_dir = $::mediawiki::dir
    $mwbzutils_dir = "${dumps_dir}/mwbzutils"
    $mwbzutils_source_dir = "${mwbzutils_dir}/xmldumps-backup/mwbzutils"
    $output_dir = "${mediawiki::apache::docroot}/dumps"
    $webroot_dir = "${mediawiki::apache::docroot}/dumps/public"

    class { '::dumps':
        conf_dir             => $conf_dir,
        dblists_dir          => $dblists_dir,
        dumps_dir            => $dumps_dir,
        mediawiki_dir        => $mediawiki_dir,
        mwbzutils_dir        => $mwbzutils_dir,
        mwbzutils_source_dir => $mwbzutils_source_dir,
        output_dir           => $output_dir,
        site_name            => $site_name,
        webroot_dir          => $webroot_dir,
    }

    mediawiki::extension { 'ActiveAbstract': }

    mediawiki::import::dump { 'seed_content':
        xml_dump           => '/vagrant/puppet/modules/dumps/files/initial-pages.xml',
        dump_sentinel_page => 'Shell_Request/Testme1234',
    }
}
