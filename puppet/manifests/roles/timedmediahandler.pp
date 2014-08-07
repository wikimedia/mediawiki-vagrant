# == Class: role::timedmediahandler
# This role provisions the TimedMediaHandler[https://www.mediawiki.org/wiki/Extension:TimedMediaHandler] extension,
# which displays audio and video files and their captions.
class role::timedmediahandler {
    include role::mediawiki
    include role::multimedia

    require_package('ffmpeg2theora')
    require_package('libav-tools')

    mediawiki::extension { 'MwEmbedSupport': }

    mediawiki::extension { 'TimedMediaHandler':
        needs_update => true,
        require      => [
            Package['libav-tools', 'ffmpeg2theora'],
            Mediawiki::Extension['MwEmbedSupport']
        ],
    }
}
