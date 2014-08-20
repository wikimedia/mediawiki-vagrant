# == Class: puppet::roles::translate
#
# The Translate extension turns MediaWiki into a tool for collaborative
# translation work, useful especially for language localisation of free software
# tools.
#
class role::translate {
    include ::role::uls

    mediawiki::extension { 'Translate':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["*"]["translate"] = true',
            '$wgGroupPermissions["sysop"]["pagetranslation"] = true',
            '$wgGroupPermissions["sysop"]["translate-manage"] = true',
            '$wgTranslateDocumentationLanguageCode = "qqq"',
            '$wgExtraLanguageNames["qqq"] = "Message documentation"',
        ],
    }
}
