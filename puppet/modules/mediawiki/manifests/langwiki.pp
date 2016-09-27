# == Define: mediawiki::langwiki
#
# This resource type represents a language wiki.
# It is like the default wiki but with language set to specific parameter.
#
# === Parameters
#
# [*language*]
#   This parameter defines the language code for the target language.
#
# [*sitename*]
#   This parameter defines the name of the site, in the language above.
#
define mediawiki::langwiki(
    $language,
    $sitename,
) {
    mediawiki::wiki { $title: }

    mediawiki::settings { "${title}wiki settings":
        wiki   => $title,
        values => {
            'wgLanguageCode' => $language,
            'wgSitename'     => $sitename,
        }
    }
}
