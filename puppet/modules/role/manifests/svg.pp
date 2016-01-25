# == Class: role::svg
# Configures MediaWiki to allow SVG upload and rendering
class role::svg {
    require_package('librsvg2-bin')

    mediawiki::settings { 'svg':
        ensure  => present,
        require => Package['librsvg2-bin'],
        values  => [
            '$wgEnableUploads = true',
            '$wgAllowTitlesInSVG = true',
            '$wgSVGConverter     = "rsvg"',
            '$wgSVGConverters["rsvg"] = \'$path/rsvg-convert -w $width -h $height $input -o $output\'',
            '$wgFileExtensions[] = "svg"',
        ],
    }
}
