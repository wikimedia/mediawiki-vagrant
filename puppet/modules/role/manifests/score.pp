# == Class: role::score
# This role provisions the
# Score[https://www.mediawiki.org/wiki/Extension:Score] extension, which
# renders musical notation via GNU LilyPond.
#
class role::score {
    include ::role::multimedia

    require_package('lilypond', 'timidity', 'freepats')

    mediawiki::extension { 'Score':
        needs_update => true,
        require      => [
            Package['lilypond'],
            Package['timidity'],
            Package['freepats'],
        ],
    }
}
