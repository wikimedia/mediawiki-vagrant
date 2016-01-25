# == Class: role::globalcssjs
# This role installs the GlobalCssJs extension on top of
# the CentralAuth extension.
#
class role::globalcssjs {
    require ::role::mediawiki
    include ::role::centralauth

    mediawiki::extension { 'GlobalCssJs':
        settings => [
            "\$wgResourceLoaderSources['wiki']['apiScript'] = '${::mediawiki::server_url}/w/api.php';",
            "\$wgResourceLoaderSources['wiki']['loadScript'] = '${::mediawiki::server_url}/w/load.php';",
            '$wgGlobalCssJsConfig["wiki"] = "wiki";',
            '$wgGlobalCssJsConfig["source"] = "wiki";',
        ],
    }
}
