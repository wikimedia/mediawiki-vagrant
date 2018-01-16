# == Class: role::globalusage
# Configures a MediaWiki instance with
# GlobalUsage[https://www.mediawiki.org/wiki/Extension:GlobalUsage]
class role::globalusage {
    require ::role::mediawiki

    mediawiki::extension { 'GlobalUsage':
        needs_update => true,
    }

    mediawiki::maintenance { 'refresh globalusage table':
        command => '/usr/local/bin/foreachwikiwithextension GlobalUsage extensions/GlobalUsage/maintenance/refreshGlobalimagelinks.php --pages existing,nonexisting',
        cwd     => $::mediawiki::dir,
        require => Mediawiki::Extension['GlobalUsage'],
    }
}
