# == Class: mathoid
#
# mathoid is a node.js backend for the math rendering.
#
# === Parameters
#
# [*port*]
#   Port the mathoid service listens on for incoming connections. (e.g 10042)
#
# [*svg*]
#   Whether to generate SVGs. Default: true
#
# [*img*]
#   Whether to generate IMGs. Default: true
#
# [*png*]
#   Whether to generate PNGs. Default: true
#
# [*texvcinfo*]
#   Whether to provide extended information on the tex input and potential problems with it.
#   Default: true
#
# [*speak_text*]
#   Whether to generate speakText representation. Default: true
#
# [*log_level*]
#   The lowest level to log (trace, debug, info, warn, error, fatal)
#
class mathoid(
    $port,
    $svg,
    $img,
    $png,
    $speak_text,
    $texvcinfo,
    $log_level = undef,
) {

    # TODO Add dependency to node-jsdom once
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=742347
    # is fixed

    require_package('openjdk-8-jre-headless')

    service::node { 'mathoid':
        port      => $port,
        log_level => $log_level,
        config    => {
            svg       => $svg,
            img       => $img,
            png       => $png,
            texvcinfo => $texvcinfo,
            speakText => $speak_text,
        },
    }

}
