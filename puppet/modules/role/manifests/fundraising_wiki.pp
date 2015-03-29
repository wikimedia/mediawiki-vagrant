# == Class: role::fundraising_wiki
# Provision a wiki using the fundraising branch.
#
# This role creates one additional wiki, fundraising.wiki.local.wmftest.net
#
# === TODO
#  There is some duplication between ::mediawiki and ::role::fundraising_wiki
#  that probably could be factored out into a ::mediawiki::branch define and
#  made to work a little more smoothly
#
# === Parameters
# [+branch+]
#   Branch of mediawiki/core.git to clone
#
# [+dir+]
#   Directory to place MediaWiki clone in
#
class role::fundraising_wiki(
    $branch,
    $dir,
) {
  require ::role::mediawiki

  git::clone { 'mediawiki-core-fr':
    remote    => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    directory => $dir,
    branch    => $branch,
  }

  mediawiki::wiki { 'fundraising':
    src_dir => $dir,
    require => [
        Git::Clone['mediawiki-core-fr'],
        Mediawiki::Wiki[$::mediawiki::wiki_name],
    ]
  }
}
