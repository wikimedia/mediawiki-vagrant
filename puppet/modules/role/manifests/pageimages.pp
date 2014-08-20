# == Class: role::pageimages
# Configures PageImages, a MediaWiki extension which provides an
# API for getting the first meaningful image on a page
class role::pageimages {
    mediawiki::extension { 'PageImages': }
}
