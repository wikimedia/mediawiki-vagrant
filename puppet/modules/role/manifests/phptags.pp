# == Class: role::phptags
# Configures PhpTags, an extension that implements the concept of Magic
# expressions with PHP language syntax in MediaWiki.
#
class role::phptags {
    mediawiki::extension { 'PhpTags': }

    mediawiki::extension { 'PhpTagsFunctions':
        require => Mediawiki::Extension['PhpTags'],
    }
    mediawiki::extension { 'PhpTagsWiki':
        require => Mediawiki::Extension['PhpTags'],
    }
}
