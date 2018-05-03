# == Class: role::sitematrix
# The sitematrix extension adds a special page with a matrix of all sites
class role::sitematrix {
    mediawiki::extension { 'SiteMatrix':
        # TODO: DB postfixes other than 'wiki' aren't supported elsewhere
        settings => "\$wgSiteMatrixSites['wiki'] = [ 'host' => 'www${mediawiki::multiwiki::base_domain}${::port_fragment}', 'name' => 'wiki' ];",
    }
}
