# == Class: role::easytimeline
# Configures the EasyTimeline extension
class role::easytimeline {
  require_package('ploticus', 'fonts-freefont-ttf')

  mediawiki::extension { 'timeline': }

  mediawiki::settings { 'TimelineFonts':
        values => {
            'wgTimelineFonts["default"]' => '/usr/share/fonts/truetype/freefont/FreeSans'
        },
  }
}
