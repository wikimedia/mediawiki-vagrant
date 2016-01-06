# == Class: role::urlgetparameters
# The UrlGetParameters extension enables you to use and/or display the "GET"
# parameters of the URL, i.e. the query string, on the wiki page.
class role::urlgetparameters {

    require ::role::mediawiki

    mediawiki::extension { 'UrlGetParameters': }
}
