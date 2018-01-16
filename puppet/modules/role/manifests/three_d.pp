# == Class: role::three_d
# This role provisions the 3D[https://www.mediawiki.org/wiki/Extension:3D] extension,
# which allows upload and viewing of 3d files.
class role::three_d {
    require ::xvfb
    include ::role::multimediaviewer
    include ::three_d

    mediawiki::extension { '3D':
        remote   => 'https://phabricator.wikimedia.org/diffusion/ETHR/3d.git',
        settings => [
            "\$wg3dProcessor = ['/usr/bin/xvfb-run', '-a', '-s', '-ac -screen 0 1280x1024x24', '${::three_d::three_d_2png_dir}/3d2png.js']",
            '$wg3dProcessEnviron = [ "DISPLAY" => ":99" ]',
            '$wgFileExtensions[] = "stl"',
            '$wgTrustedMediaFormats[] = "application/sla"',
            '$wgMediaViewerExtensions["stl"] = "mmv.3d"',
        ]
    }
}
