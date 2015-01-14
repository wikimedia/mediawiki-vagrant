# == Class: role::livingstyleguide
# Sets up a 'living style guide' wiki, with the custom Blueprint skin.
# This wiki will be available, by default, at livingstyleguide.
class role::livingstyleguide {
  mediawiki::wiki {'livingstyleguide': }

  mediawiki::extension { 'OOUIPlayground':
      composer => true,
      wiki     => 'livingstyleguide',
  }

  mediawiki::skin { 'Blueprint':
      default  => true,
      composer => true,
      wiki     => 'livingstyleguide',
  }
}
