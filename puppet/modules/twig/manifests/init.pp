# == Class: twig
#
# Wikimedia redistribution of http://twig.sensiolabs.org/
#
# === Parameters
#
# [*dir*]
#   Root directory for the Twig package
#
class twig(
    $dir = '/srv/twig',
) {
    git::clone { 'wikimedia/fundraising/twig':
        directory => $dir,
    }
}
