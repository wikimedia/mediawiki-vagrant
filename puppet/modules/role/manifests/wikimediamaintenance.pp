# == Class: role::wikimediamaintenance
#
# Provision the WikimediaMaintenance extension
#
class role::wikimediamaintenance {
    mediawiki::extension { 'WikimediaMaintenance': }
}
