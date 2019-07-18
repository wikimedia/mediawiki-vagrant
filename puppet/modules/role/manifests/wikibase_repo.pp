# == Class: role::wikibase_repo
#
# This role sets up a plain Wikibase repo installation including all dependent components.
# It provides a quick way to get ready for hacking on Wikibase code.
#
# This role doesn't use any magic such as WikidataBuildResources and
# doesn't set up any client wikis. If you want a full Wikidata installation including
# multiple client wikis, use role::wikidata instead.
# The Wikibase repo is only enabled on the main wiki. Apply the mediawiki::settings block below
# or something similar to enable it there.
#
# Todo:
# Support for badges
#
class role::wikibase_repo {
  require ::role::mediawiki
  include ::wikibase
  include ::role::sitematrix
  include ::role::wikimediamessages

  # Bootstrapping settings to be run before loading the extension.
  # Global settings/extension loads always precede per-wiki ones
  # in Vagrant so we have to pretend this is a global one and use
  # hackier means to bind to a specific wiki.
  mediawiki::settings { 'Wikibase-Role-Init':
    priority => $::load_early,
    header   => 'if ( $wgDBname === "wiki" ) {',
    values   => {
      'wgEnableWikibaseRepo' => true,
    },
    footer   => '}',
  }

  # Extension settings to be run after loading the extension.
  # This uses the 'wiki' option so no point in setting priority.
  mediawiki::settings { 'Wikibase-Role-Config':
    wiki   => 'devwiki',
    values => template('role/wikibase_repo/init.php.erb'),
  }
}
