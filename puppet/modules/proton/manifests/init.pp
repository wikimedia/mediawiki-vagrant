# == Class: proton
# Sets up the Proton[https://www.mediawiki.org/wiki/Proton]
# service which renders PDF files from web pages.
#
# === Parameters
#
# [*port*]
#   The port proton listens
#
# [*dir*]
#   Service directory
#
# [*log_file*]
#   Log file.
#
class proton(
    $port,
    $dir,
    $log_file,
) {
    include ::git
    require ::role::mediawiki

    require_package([
        'chromium',
        'fonts-liberation',
        'fonts-noto',
    ])

    service::node { 'proton':
        port         => $port,
        git_remote   => sprintf($::git::urlformat, 'mediawiki/services/chromium-render'),
        config       => template('proton/config.yaml.erb'),
        environment  => {
            'APP_ENABLE_CANCELLABLE_PROMISES' => true,
            'PUPPETEER_EXECUTABLE_PATH'       => '/usr/bin/chromium',
        },
        node_version => '18',
        require      => Package['chromium', 'fonts-liberation', 'fonts-noto'],
    }
}
