# == Class: role::cldr
# The CLDR extension provides functions to localize the names of languages,
# countries, and currencies based on their language code, using data extracted
# from the Common Locale Data Repository (CLDR), a project of the Unicode
# Consortium to provide locale data in the XML format for use in computer
# applications.
class role::cldr {
    require_package('unzip')

    mediawiki::extension { 'cldr':
        priority => $::load_later,
    }
}
