# == Class: role::timedmediahandler
# This role provisions the [TimedMediaHandler][1] extension,
# which displays audio and video files and their captions.
#
# [1] https://www.mediawiki.org/wiki/Extension:TimedMediaHandler
class role::timedmediahandler {
    include role::mediawiki
    include role::multimedia

    include packages::ffmpeg
    include packages::ffmpeg2theora

    mediawiki::extension { 'MwEmbedSupport': }

    mediawiki::extension { 'TimedMediaHandler':
        needs_update => true,
        require      => [
            Package['ffmpeg', 'ffmpeg2theora'],
            Mediawiki::Extension['MwEmbedSupport']
        ],
    }
}
