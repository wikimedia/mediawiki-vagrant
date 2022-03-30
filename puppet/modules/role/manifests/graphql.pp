# == Class: role::graphql
# Configures GraphQL, a MediaWiki extension that exposes
# a GraphQL API endpoint for MediaWiki
class role::graphql {
    include ::npm

    mediawiki::extension { 'GraphQL':
        composer => true
    }

    npm::install { 'graphql':
        directory => '/vagrant/mediawiki/extensions/GraphQL'
    }
}
