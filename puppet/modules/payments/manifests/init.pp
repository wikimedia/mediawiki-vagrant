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
    $drupal_db,
    $drupal_db_user,
    $drupal_db_pass,
) {
  include ::payments::donation_interface
  include ::crm

  git::clone { 'mediawiki-core-fr':
    remote    => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    directory => $dir,
    branch    => $branch,
  }

  php::composer::install { 'mediawiki-dependencies':
    directory => $dir,
    require   => Git::Clone['mediawiki-core-fr'],
  }

  mediawiki::wiki { 'payments':
    src_dir => $dir,
    require => [
      Git::Clone['mediawiki-core-fr'],
      Mediawiki::Wiki[$::mediawiki::wiki_name],
      Php::Composer::Install['mediawiki-dependencies'],
    ],
  }

  mediawiki::extension { [
    'payments:ParserFunctions',
  ]: }

  mediawiki::extension { 'payments:FundraisingEmailUnsubscribe':
    needs_update => true,
    settings     => {
      'wgFundraisingEmailUnsubscribeQueueParameters' => {
        'unsubscribe' => {
          'servers' => {
            'scheme' => 'tcp',
            'host'   => 'localhost',
            'port'   => 6379,
          },
        },
        'opt-in'      => {
          'servers' => {
            'scheme' => 'tcp',
            'host'   => 'localhost',
            'port'   => 6379,
          },
        },
      },
    },
  }

  mediawiki::import::text { 'payments:Main_Page':
      # N.b. - Creepy abnormal multiwiki syntax
      wiki       => 'payments',
      db_name    => 'paymentswiki',
      page_title => 'Main_Page',
      source     => 'puppet:///modules/payments/Main_Page.wiki',
  }

  mediawiki::import::text { 'payments:Donate-error':
      wiki       => 'payments',
      db_name    => 'paymentswiki',
      page_title => 'Donate-error',
      source     => 'puppet:///modules/payments/Donate-error.wiki',
  }

  mediawiki::import::text { 'payments:Donate-thanks':
      wiki       => 'payments',
      db_name    => 'paymentswiki',
      page_title => 'Donate-thanks',
      source     => 'puppet:///modules/payments/Donate-thanks.wiki',
  }

  mediawiki::import::text { 'payments:Template:LanguageSwitch':
      wiki       => 'payments',
      db_name    => 'paymentswiki',
      page_title => 'Template:LanguageSwitch',
      source     => 'puppet:///modules/payments/LanguageSwitch.wiki',
  }

  mediawiki::import::text { 'payments:Template:2011FR/JimmyQuote/text/en':
      wiki       => 'payments',
      db_name    => 'paymentswiki',
      page_title => 'Template:2011FR/JimmyQuote/text/en',
      source     => 'puppet:///modules/payments/Appeal.wiki',
  }
}
