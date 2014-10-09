# == Class: role::nuke
# This role provisions the Nuke [https://www.mediawiki.org/wiki/Extension:Nuke] extension,
# which gives sysops the ability to mass delete pages
class role::nuke {
  mediawiki::extension { 'Nuke': }
}