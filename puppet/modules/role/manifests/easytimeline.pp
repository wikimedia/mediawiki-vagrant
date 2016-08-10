# == Class: role::easytimeline
# Configures the EasyTimeline extension
class role::easytimeline {
  require_package('ploticus', 'ttf-freefont')

  mediawiki::extension { 'timeline': }
}
