# == Class: role::globalcssjs
# This role installs the GlobalCssJs extension on top of
# the CentralAuth extension. It additionally adds a
# globalcssjstest.wiki.local.wmftest.net which will also
# load your global scripts.
#
class role::globalcssjs {
    require ::role::mediawiki
    include ::role::centralauth

    $common_settings = [
      "\$wgResourceLoaderSources['wiki']['apiScript'] = 'http://127.0.0.1:${::forwarded_port}/w/api.php';",
      "\$wgResourceLoaderSources['wiki']['loadScript'] = 'http://127.0.0.1:${::forwarded_port}/w/load.php';",
      '$wgGlobalCssJsConfig["wiki"] = "wiki";',
      '$wgGlobalCssJsConfig["source"] = "wiki";',
    ]

    mediawiki::extension { 'GlobalCssJs':
        settings     => $common_settings,
    }

    multiwiki::wiki{ 'globalcssjstest': }

    role::globalcssjs::multiwiki { 'globalcssjstest': }
}

# == Define: ::role::globalcssjs::multiwiki
# Configure a multiwiki instance for GlobalCssJs.
#
define role::globalcssjs::multiwiki {
    $wiki = $title

    multiwiki::extension { "${wiki}:GlobalCssJs":
        settings     => $::role::globalcssjs::common_settings,
    }
}
