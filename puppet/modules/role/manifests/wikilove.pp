# == Class: role::wikilove
# The WikiLove extension lets people send love to other wiki users
# in the form of the Internet's most preferred currency, kittens.
class role::wikilove {
    mediawiki::extension { 'WikiLove':
        needs_update => true,
        settings     => {
            wgWikiLoveGlobal => true,
        }
    }
}
