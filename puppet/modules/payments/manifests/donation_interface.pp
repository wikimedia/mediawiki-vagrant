# == Class: payments::donation_interface
# Configure the DonationInterface extension
#
class payments::donation_interface {

  mediawiki::extension { 'payments:DonationInterface':
    settings     => {
      wgGlobalCollectGatewayEnabled             => true,
      wgIngenicoGatewayEnabled                  => true,
      wgAdyenGatewayEnabled                     => true,
      wgAmazonGatewayEnabled                    => true,
      wgAstroPayGatewayEnabled                  => true,
      wgPaypalGatewayEnabled                    => true,
      wgPaypalExpressGatewayEnabled             => true,
      wgDonationInterfaceEnableFormChooser      => true,
      wgDonationInterfaceEnableBannerHistoryLog => true,
      wgDonationInterfaceEnableQueue            => true,
      wgDonationInterfaceEnableSystemStatus     => true,
      wgDonationInterfaceEnableFunctionsFilter  => true,
      wgDonationInterfaceEnableMinfraud         => false,
      wgDonationInterfaceEnableReferrerFilter   => true,
      wgDonationInterfaceEnableSourceFilter     => true,

      wgDonationInterfaceTest                   => true,

      wgAdyenGatewayAccountInfo                 => {
        'test' => {
          'AccountName'  => 'test',
          'SkinCode'     => 'test',
          'SharedSecret' => 'test',
          'PublicKey'    => 'test',
        },
      },
      wgDonationInterfaceAdyenPublicKey         => '10001|9C916360EC9BD4530A9BCF8367069EDD88E48E0569310B8653452723372B1635035E3DE63D1EF882D17918E0E6EA73D8248815C2D95E8D2EAE6F65A0D8359E903AB84024A3230F6A05797C9116FA0264FCD00E5ED3A2BC0FA897E74DAA4496337318507659EF5D03974D92204C9464C197B1E11FA7814442751EA069EFC2E470A9E82A8E621D899A02C4173B4019F74F16A59B22336421639BAC1513644EEE47298CCBAA681C1E8F0B00B0BC18638BA7FEA22FC394972ACE4BD7038E866CF3FFBF20FB860669137083EE73DD53DE5934ADC6378B9',

      wgGlobalCollectGatewayAccountInfo         => {
        'test' => {
          'MerchantID' => 'test'
        }
      },

      wgPaypalGatewayURL                        => 'https://www.sandbox.paypal.com/cgi-bin/webscr',

      wgDonationInterfaceMemcacheHost           => 'localhost',

      wgDonationInterfaceUseSyslog              => true,

    },
    needs_update => true,
    require      => [
      Mediawiki::Extension[
        'payments:ContributionTracking'
      ],
    ],
  }
}
