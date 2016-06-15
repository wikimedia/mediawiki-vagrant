# == Class: role::kartographerwv
# Configures Kartographer with Wikivoyage customizations, an extension for display maps in wiki pages
class role::kartographerwv {

    include ::role::kartographer

    mediawiki::settings { 'KartographerWV':

        values => {
            'wgKartographerWikivoyageMode' => true,
            'wgKartographerUseMarkerStyle' => true,
        },
    }

}
