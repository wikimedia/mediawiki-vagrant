# == Class: payments
# Provision a payments wiki using the fundraising deployment branch.
#
# This role creates one additional wiki, payments.wiki.local.wmftest.net
#
# === TODO
#  * Push wiki config down into the payments_wiki module.
#
#  * There is some duplication between ::mediawiki and ::role::payments
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
class payments(
    $branch,
    $dir,
) {
  require ::role::mediawiki
  include ::payments::donation_interface

  git::clone { 'mediawiki-core-fr':
    remote    => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    directory => $dir,
    branch    => $branch,
  }

  mediawiki::wiki { 'payments':
    src_dir => $dir,
    require => [
      Git::Clone['mediawiki-core-fr'],
      Mediawiki::Wiki[$::mediawiki::wiki_name],
    ],
  }

  mediawiki::extension { 'payments:FundraisingEmailUnsubscribe':
    entrypoint => 'FundraiserUnsubscribe.php',
  }

  mediawiki::extension { 'payments:ParserFunctions': }

  mediawiki::import_text { 'payments:Main_Page':
      source  => 'puppet:///modules/payments/Main_Page.wiki',
  }
}
