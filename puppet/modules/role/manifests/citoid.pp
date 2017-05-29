# == Class: role::citoid
# Provisions Citoid, a MediaWiki extension which adds an auto-
# filled citation tool to VisualEditor using the citoid service.
class role::citoid(
    $url,
) {
    include ::citoid

    mediawiki::extension { 'Citoid':
        settings => {
            wgCitoidServiceUrl => $url,
        }
    }

    mediawiki::import::text { 'VagrantRoleCitoid':
        content => template('role/citoid/VagrantRoleCitoid.wiki.erb'),
    }
}
