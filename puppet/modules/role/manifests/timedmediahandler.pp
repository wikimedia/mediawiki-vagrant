# == Class: role::timedmediahandler
# This role provisions the TimedMediaHandler[https://www.mediawiki.org/wiki/Extension:TimedMediaHandler] extension,
# which displays audio and video files and their captions.
class role::timedmediahandler {
    include ::role::multimedia

    require_package('ffmpeg')
    require_package('fluidsynth')
    require_package('fluid-soundfont-gm')

    mediawiki::extension { 'TimedMediaHandler':
        settings     => {
            wgWaitTimeForTranscodeReset => 1,
            wgFFmpegLocation            => '/usr/bin/ffmpeg',
            wgTmhFluidsynthLocation     => '/usr/bin/fluidsynth',
            wgTmhSoundfontLocation      => '/usr/share/sounds/sf2/FluidR3_GM.sf2'
        },
        needs_update => true,
        composer     => true,
        require      => [
            Package['ffmpeg'],
            Package['fluidsynth'],
            Package['fluid-soundfont-gm']
        ],
    }
}
