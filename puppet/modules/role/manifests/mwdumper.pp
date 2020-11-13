# == Class: role::mwdumper
#
# Install the mwdumper[https://www.mediawiki.org/wiki/Manual:MWDumper]
# command line tool for importing MediaWiki dumps.
#
class role::mwdumper {
    require ::role::mediawiki

    require_package(['maven', 'default-jdk'])

    $mwdumper_dir = "${::mwv::services_dir}/mwdumper"
    $mwdumper_file = "${mwdumper_dir}/target/mwdumper-1.25.jar"

    git::clone { 'mediawiki/tools/mwdumper':
        # not really a service but close enough...
        directory => $mwdumper_dir,
    }

    exec { 'compile MWDumper':
        # see https://stackoverflow.com/a/53085816/323407 for the _JAVA_OPTIONS hack
        # needed as of 2019-01; should be removed once unnecessary
        command => 'mvn compile; _JAVA_OPTIONS=-Djdk.net.URLClassPath.disableClassPathURLCheck=true mvn package',
        creates => $mwdumper_file,
        cwd     => $mwdumper_dir,
        require => [
            Package['maven', 'default-jdk'],
            Git::Clone['mediawiki/tools/mwdumper'],
        ],
    }

    file { '/usr/local/bin/mwdumper':
        ensure  => 'file',
        content => template('role/mwdumper/mwdumper.erb'),
        mode    => 'a+x',
    }

    mediawiki::import::text { 'VagrantRoleMwdumper':
        content => template('role/mwdumper/VagrantRoleMwdumper.wiki.erb'),
    }
}
