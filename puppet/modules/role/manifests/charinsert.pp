# == Class: role::charinsert
# Installs the CharInsert extension.
#
# https://www.mediawiki.org/wiki/Extension:CharInsert
#
class role::charinsert {

  mediawiki::extension { 'CharInsert': }
}
