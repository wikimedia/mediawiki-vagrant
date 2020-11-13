# == Class: role::relatedarticles
#
# Installs the RelatedArticles[https://www.mediawiki.org/wiki/Extension:RelatedArticles]
# extension which shows some related articles (based on content
# similarity, can be overriden via a parser tag).
#
class role::relatedarticles {
    mediawiki::extension { 'RelatedArticles':
        settings => {
            wgRelatedArticlesShowInSidebar   => false,
            wgRelatedArticlesShowInFooter    => true,
            wgRelatedArticlesUseCirrusSearch => true,
        }
    }
}
