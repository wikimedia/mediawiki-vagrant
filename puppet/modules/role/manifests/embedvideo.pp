# == Class: role::embedvideo
# Installs EmbedVideo extension
class role::embedvideo {
    mediawiki::extension { 'EmbedVideo':
        remote => 'https://github.com/Alexia/mediawiki-embedvideo.git'
    }
}
