# == Class mediawiki::extension::wikidiff2
#
class mediawiki::extension::wikidiff2 {
    apt::pin { 'wikidiff2':
        package  => 'php-wikidiff2',
        pin      => 'release a=stretch-backports',
        priority => 1001,
    }
}
