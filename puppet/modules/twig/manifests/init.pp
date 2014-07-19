# == Class: twig
#
# Wikimedia Fundraising's fork of Twig, a PHP templating engine.
# See <http://twig.sensiolabs.org/>.
#
# === Parameters
#
# [*dir*]
#   Root directory for the Twig package
#
class twig( $dir = '/srv/twig' ) {
    git::clone { 'wikimedia/fundraising/twig':
        directory => $dir,
    }
}
