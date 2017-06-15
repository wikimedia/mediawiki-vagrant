# == Class: role::relatedarticles
#
# Installs the RelatedArticles[1] extension which shows some related
# articles (based on content similarity, can be overriden via a parser
# tag).
#
# [1] https://www.mediawiki.org/wiki/Extension:RelatedArticles
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
