# == Class: role::score
# This role provisions the
# Score[https://www.mediawiki.org/wiki/Extension:Score] extension, which
# renders musical notation via GNU LilyPond.
#
class role::score {
    include ::role::multimedia

    require_package('lilypond', 'fluidsynth', 'fluid-soundfont-gs', 'fluid-soundfont-gm')

    mediawiki::extension { 'Score':
        needs_update => true,
        require      => [
            Package['lilypond'],
            Package['fluidsynth'],
            Package['fluidsynth-soundfont-gs'],
            Package['fluidsynth-soundfont-gm'],
        ],
    }
}
