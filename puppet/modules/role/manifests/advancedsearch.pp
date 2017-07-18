# == Class: role::advancedsearch
class role::advancedsearch {
  include ::role::betafeatures
  mediawiki::extension { 'AdvancedSearch': }
}
