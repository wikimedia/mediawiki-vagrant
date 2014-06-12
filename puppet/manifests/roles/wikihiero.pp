# == Class: role::mantle
# Configures WikiHiero, an extension for displaying Egyptian hieroglyphs
class role::wikihiero {
  mediawiki::extension { 'wikihiero':
    needs_update => true,
  }
}
