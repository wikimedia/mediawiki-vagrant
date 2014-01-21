# == Class: mathsearch
#
# Module for the extension math search.
#
class mathsearch {

    exec { "switch to dev branch of math":
        command     => "git checkout -b dev origin/dev",
        onlyif      => "git status | grep -c 'master'",
        cwd         => "/vagrant/mediawiki/extensions/Math",
        require     => [ Package['git'], Mediawiki::Extension['Math'] ],
        environment => 'HOME=/home/vagrant',
        timeout     => 0,
    }

    mediawiki::extension { 'MathSearch':
        needs_update => true,
        settings => template('mathsearch/MathSearch.php.erb'),
    }
}
