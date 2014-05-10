# == Class: role::sitematrix
# The sitematrix extension adds a special page with a matrix of all sites
class role::sitematrix {
    mediawiki::extension { 'SiteMatrix': }
}
