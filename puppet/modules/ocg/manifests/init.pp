# == Class: ocg
# Sets up the OCG[https://www.mediawiki.org/wiki/Offline_content_generator] service
# for rendering PDF books from groups of wiki articles.
# See wikitech[https://wikitech.wikimedia.org/wiki/OCG] for technical documentation.
#
# === Parameters
#
# [*port*]
#   Port to listen on
#
class ocg(
    $port,
) {
    include role::restbase

    require_package([
        'texlive-xetex',
        'texlive-latex-recommended',
        'texlive-latex-extra',
        'texlive-generic-extra',
        'texlive-fonts-recommended',
        'texlive-fonts-extra',
        'fonts-hosny-amiri',
        'fonts-farsiweb',
        'fonts-nafees',
        'fonts-arphic-uming',
        'fonts-arphic-ukai',
        'fonts-droid-fallback',
        'fonts-baekmuk',
        'lmodern',
        'texlive-lang-all',
        'latex-xcolor',
        'poppler-utils',
        'imagemagick',
        'librsvg2-bin',
        'libjpeg-progs',
        'djvulibre-bin',
        'unzip',
    ])

    $remote_suffix_hash = {
        mw-ocg-service => '',
        mw-ocg-bundler => '/bundler',
        mw-ocg-latexer => '/latex_renderer',
        mw-ocg-texter  => '/text_renderer',
    }
    $keys = keys($remote_suffix_hash)
    ocg::service{ $keys: hash => $remote_suffix_hash }

    $parsoid_port = $::parsoid::port
    $dir = "${::service::root_dir}/mw-ocg-service"
    $config = "${::service::root_dir}/mw-ocg-service/localsettings.js"
    $log_dir = $::service::log_dir

    file { $config:
        content => template('ocg/localsettings.js.erb'),
        require => Git::Clone['mw-ocg-service'],
    }

    systemd::service { 'mw-ocg-service':
        service_params => {
            subscribe => [ Npm::Install[$dir], File[$config] ],
        },
        require        => Ocg::Service[keys($remote_suffix_hash)],
    }
}
