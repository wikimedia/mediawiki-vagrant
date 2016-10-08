# == Class: role::kartographer
# Configures Kartographer, an extension for display maps in wiki pages
class role::kartographer {

    include ::role::wikimediamessages

    mediawiki::extension { 'Kartographer':
        composer => true,
    }
}
