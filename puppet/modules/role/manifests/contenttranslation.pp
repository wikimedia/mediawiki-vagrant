# == Class: role::contentration
#
# ContentTranslation is a tool for creating new articles in a
# target language from existing articles in a source language.
#
# This manifest supports installing the ContentTranslation extension,
# the cxserver service and all the necessary dependencies. For more
# detailed information see: puppet/modules/contenttranslation.
#
# == Customization
#
# Default values are defined in /vagrant/puppet/hieradata/common.yaml
# To customize your installation, create a file called 'local.yaml'
# in the same location and include entries for the settings you want
# to override.
#
class role::contenttranslation {
  include ::role::betafeatures
  include ::role::eventlogging
  include ::role::cldr
  include ::role::uls
  include ::role::visualeditor
  include ::role::echo
  include ::role::globalpreferences
  include ::contenttranslation::cxserver
  include ::contenttranslation
}
