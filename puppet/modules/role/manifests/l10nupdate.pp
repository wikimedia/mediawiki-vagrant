# == Class: role::l10update
#
# Install the LocalisationUpdate extension
#
class role::l10nupdate {
    mediawiki::extension { 'LocalisationUpdate':
        settings => {
            'wgLocalisationUpdateDirectory' => '$wgCacheDirectory',
        },
    }
}
