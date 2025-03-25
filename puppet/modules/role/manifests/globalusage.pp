# == Class: role::globalusage
# Configures a MediaWiki instance with
# GlobalUsage[https://www.mediawiki.org/wiki/Extension:GlobalUsage]
class role::globalusage {
    require ::role::mediawiki

    mediawiki::extension { 'GlobalUsage':
        needs_update => true,
    }

    mediawiki::maintenance { 'refresh globalusage table':
        command     => '/usr/local/bin/foreachwikiwithextension GlobalUsage extensions/GlobalUsage/maintenance/refreshGlobalimagelinks.php --pages existing,nonexisting',
        cwd         => $::mediawiki::dir,
        refreshonly => true,
        require     => Mediawiki::Extension['GlobalUsage'],
    }

    Mediawiki::Extension['GlobalUsage'] ~> Mediawiki::Maintenance['refresh globalusage table']
    Mediawiki::Wiki<| |> ~> Mediawiki::Maintenance['refresh globalusage table']
}
