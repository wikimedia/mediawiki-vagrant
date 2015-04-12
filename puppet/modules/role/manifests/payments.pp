# == Class: role::payments
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
class role::payments(
    $branch,
    $dir,
) {
  require ::role::mediawiki

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
    ]
  }

  mediawiki::extension { 'payments:ContributionTracking':
    needs_update => true,
  }

  mediawiki::extension { 'payments:FundraisingEmailUnsubscribe':
    entrypoint => 'FundraiserUnsubscribe.php',
    # FIXME: don't require: wgTwigPath => "${::twig::dir}/current/lib/Twig",
  }

  mediawiki::extension { 'payments:ParserFunctions': }

  # FIXME: Use relative paths to load forms.
  $DI = "${dir}/extensions/DonationInterface"

  mediawiki::extension { 'payments:DonationInterface':
    settings     => {
      wgDonationInterfaceEnableAdyen         => true,
      wgDonationInterfaceEnableAmazon        => true,
      wgDonationInterfaceEnableFormChooser   => true,
      wgDonationInterfaceEnableGlobalCollect => true,
      wgDonationInterfaceEnablePaypal        => true,
      wgDonationInterfaceEnableQueue         => true,
      wgDonationInterfaceEnableStomp         => true,
      wgDonationInterfaceTestMode            => true,

      # TODO: the following cruft is brought to u by a forward reference snafu.
      # Better if DonationInterfaceFormSettings would use relative paths?
      wgAdyenGatewayHtmlFormDir              => "${DI}/adyen_gateway/forms/html",
      wgAmazonGatewayHtmlFormDir             => "${DI}/amazon_gateway/forms/html",
      wgGlobalCollectGatewayHtmlFormDir      => "${DI}/globalcollect_gateway/forms/html",
      wgPayflowProGatewayHtmlFormDir         => "${DI}/payflowpro_gateway/forms/html",
      wgPaypalGatewayHtmlFormDir             => "${DI}/paypal_gateway/forms/html",

      wgAdyenGatewayAccountInfo              => {
        'test' => {
          'AccountName'  => 'test',
          'SkinCode'     => 'test',
          'SharedSecret' => 'test',
          'PublicKey'    => 'test',
        },
      },
      wgDonationInterfaceAdyenPublicKey      => '10001|9C916360EC9BD4530A9BCF8367069EDD88E48E0569310B8653452723372B1635035E3DE63D1EF882D17918E0E6EA73D8248815C2D95E8D2EAE6F65A0D8359E903AB84024A3230F6A05797C9116FA0264FCD00E5ED3A2BC0FA897E74DAA4496337318507659EF5D03974D92204C9464C197B1E11FA7814442751EA069EFC2E470A9E82A8E621D899A02C4173B4019F74F16A59B22336421639BAC1513644EEE47298CCBAA681C1E8F0B00B0BC18638BA7FEA22FC394972ACE4BD7038E866CF3FFBF20FB860669137083EE73DD53DE5934ADC6378B9',

      wgGlobalCollectGatewayAccountInfo      => {
        'test' => {
          'MerchantID' => 'test'
        }
      },

      wgPaypalGatewayURL                     => 'https://www.sandbox.paypal.com/cgi-bin/webscr',

      wgStompServer                          => 'tcp://localhost:61613',

      wgDonationInterfaceUseSyslog           => true,
    },
    needs_update => true,
    require      => [
      Mediawiki::Extension[
        'payments:ContributionTracking',
        'payments:FundraisingEmailUnsubscribe',
        'payments:ParserFunctions'
      ],
    ],
  }

  mediawiki::settings { 'payments:DonationInterfaceFormSettings':
    values => {},
    footer => "require_once( '${dir}/DonationInterfaceFormSettings.php' );"
  }
}
