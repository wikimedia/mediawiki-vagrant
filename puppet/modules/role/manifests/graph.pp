# == Class: role::graph
# Configures Graph extension
class role::graph {
    include ::role::jsonconfig

    mediawiki::extension { 'Graph':
        settings => {
            wgGraphDefaultVegaVer => 2,
            wgGraphAllowedDomains => {
                http           => [
                    "localhost${::port_fragment}",
                    "127.0.0.1${::port_fragment}",
                    "dev.wiki.local.wmftest.net${::port_fragment}",
                    'wmflabs.org',
                    'vega.github.io',
                ],
                https          => [
                    'mediawiki.org',
                    'wikibooks.org',
                    'wikidata.org',
                    'wikimedia.org',
                    'wikimediafoundation.org',
                    'wikinews.org',
                    'wikipedia.org',
                    'wikiquote.org',
                    'wikisource.org',
                    'wikiversity.org',
                    'wikivoyage.org',
                    'wiktionary.org',
                ],
                wikirawupload  => [
                    'upload.wikimedia.org',
                    'upload.beta.wmflabs.org',
                    "localhost${::port_fragment}",
                    "dev.wiki.local.wmftest.net${::port_fragment}",
                ],
                wikidatasparql => [
                    'query.wikidata.org',
                    'wdqs-test.wmflabs.org',
                ],
                geoshape       => [
                    'maps.wikimedia.org',
                ],
            },
        },
    }
}
