# == Class: role::uls
# The Universal Language Selector extension (ULS) provides a flexible
# way to configure and deliver language settings like interface
# language, fonts, and input methods (keyboard mappings). This will
# allow users to type text in different languages not directly supported
# by their keyboard, read content in a script for which fonts are not
# available locally, or customize the language in which menus are
# displayed.
class role::uls {
    mediawiki::extension { 'UniversalLanguageSelector':
        settings => { wgULSEnable => true },
    }
}
