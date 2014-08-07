# == Class: role::svg
# Configures MediaWiki to allow SVG upload and rendering
class role::svg {
    include role::mediawiki

    include packages::librsvg2_bin

    mediawiki::settings { 'svg':
        ensure  => present,
        require => Package['librsvg2-bin'],
        values => [
            '$wgEnableUploads = true',
            '$wgAllowTitlesInSVG = true',
            '$wgSVGConverter     = \'rsvg\'',
            '$wgSVGConverters[\'rsvg\'] = \'$path/rsvg-convert -w $width -h $height $input -o $output\'',
            '$wgFileExtensions[] = \'svg\'',
        ],
    }
}
