# == Class mediawiki::extension::wikidiff2
#
class mediawiki::extension::wikidiff2 {
    apt::pin { 'wikidiff2':
        package  => 'php7.4-wikidiff2',
        pin      => 'release a=buster-backports',
        priority => 1001,
    }
}
