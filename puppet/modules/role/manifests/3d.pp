# == Class: role::3d
# This role provisions the 3d[https://www.mediawiki.org/wiki/Extension:3d] extension,
# which allows upload and viewing of 3d files.
class role::3d {
    require ::xvfb
    include ::role::multimediaviewer
    include ::3d

    mediawiki::extension { '3d':
        remote   => 'https://phabricator.wikimedia.org/diffusion/ETHR/3d.git',
        settings => [
            "\$wg3dProcessor = \"${::3d::3d2png_dir}/3d2png.js\"",
            '$wg3dProcessEnviron = [ "DISPLAY" => ":99" ]',
            '$wgFileExtensions[] = "amf"',
            '$wgFileExtensions[] = "stl"',
            '$wgTrustedMediaFormats[] = "application/x-amf"',
            '$wgTrustedMediaFormats[] = "application/sla"',
            '$wgXMLMimeTypes["amf"] = "application/x-amf"',
            '$wgMediaViewerExtensions["stl"] = "mmv.3d"',
            '$wgMediaViewerExtensions["amf"] = "mmv.3d"',
        ]
    }
}
