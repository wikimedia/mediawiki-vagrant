# == Roles for Mediawiki-Vagrant
#
# A 'role' represents a set of software configurations required for
# giving this machine some special function. If you'd like to use the
# Vagrant-Mediawiki codebase to describe a development environment that
# you could then share with other developers, you should do so by adding
# a role below and submitting it as a patch to the Mediawiki-Vagrant
# project.
#
# *Note*:: If your role depends on packages, please create a package
#   class for each dependency in packages.pp rather than declare the
#   package resource in the role itself. This allows packages to be
#   used by multiple roles.
#

# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
    class { 'apt':
        stage => first,
    }
    class { 'env': }
    class { 'misc': }
    class { 'git': }
}

# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and redis.
class role::mediawiki {
    include role::generic

    $wiki_name = 'devwiki'

    # 'forwarded_port' defaults to 8080, but may be overridden by
    # changing the value of 'FORWARDED_PORT' in Vagrantfile.
    $server_url = "http://127.0.0.1:${::forwarded_port}"
    $dir = '/vagrant/mediawiki'
    $settings_dir = '/vagrant/settings.d'
    $upload_dir = '/srv/images'

    # Database access
    $db_name = 'wiki'
    $db_user = 'root'
    $db_pass = 'vagrant'

    # Initial admin account
    $admin_user = 'admin'
    $admin_pass = 'vagrant'

    class { '::redis':
        persist => true
    }

    class { '::mysql':
        default_db_name => $db_name,
        root_password   => $db_pass,
    }

    class { '::mediawiki':
        wiki_name    => $wiki_name,
        admin_user   => $admin_user,
        admin_pass   => $admin_pass,
        db_name      => $db_name,
        db_pass      => $db_pass,
        db_user      => $db_user,
        dir          => $dir,
        settings_dir => $settings_dir,
        upload_dir   => $upload_dir,
        server_url   => $server_url,
    }

    @mediawiki::extension { 'Vector': }
}

# == Class: role::fundraising
# This role configures MediaWiki to use the 'fundraising/1.22' branch
# and sets up the ContributionTracking, FundraisingEmailUnsubscribe, and
# DonationInterface extensions.
class role::fundraising {
    include role::mediawiki
    include packages::rsyslog

    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        require    => Package['rsyslog'],
        hasrestart => true,
    }

    file { '/etc/rsyslog.d/60-payments.conf':
        content => template('fr-payments-rsyslog.conf.erb'),
        require => Package['rsyslog'],
        notify  => Service['rsyslog'],
    }

    exec { 'checkout fundraising branch':
        command => 'git checkout --track origin/fundraising/1.22',
        unless  => 'git branch --list | grep -q fundraising/1.22',
        cwd     => $mediawiki::dir,
        require => Exec['mediawiki setup'],
    }

    @mediawiki::extension { [ 'ContributionTracking', 'ParserFunctions' ]: }

    @mediawiki::extension { 'FundraisingEmailUnsubscribe':
        entrypoint => 'FundraiserUnsubscribe.php',
    }

    @mediawiki::extension { 'DonationInterface':
        entrypoint   => 'donationinterface.php',
        settings     => template('fr-config.php.erb'),
        needs_update => true,
        require      => [
            File['/etc/rsyslog.d/60-payments.conf'],
            Exec['checkout fundraising branch'],
            Mediawiki::Extension[
                'ContributionTracking',
                'FundraisingEmailUnsubscribe',
                'ParserFunctions'
            ],
        ],
    }
}


# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against production schemas but logged locally.
class role::eventlogging {
    include role::mediawiki

    @mediawiki::extension { 'EventLogging':
        priority => 5,
        settings => {
            # Work with production schemas but log locally:
            wgEventLoggingBaseUri        => 'http://localhost:8100/event.gif',
            wgEventLoggingFile           => '/vagrant/logs/eventlogging.log',
            wgEventLoggingSchemaIndexUri => 'http://meta.wikimedia.org/w/index.php',
            wgEventLoggingDBname         => 'metawiki',
        }
    }
}

# == Class: role::mobilefrontend
# Configures MobileFrontend, the MediaWiki extension which powers
# Wikimedia mobile sites.
class role::mobilefrontend {
    include role::mediawiki
    include role::eventlogging

    @mediawiki::extension { 'MobileFrontend':
        settings => {
            wgMFForceSecureLogin => false,
            wgMFLogEvents        => true,
        }
    }
}

# == Class: role::guidedtour
# Configures Guided Tour, a MediaWiki extension which provides a
# framework for creating "guided tours", or interactive tutorials
# for MediaWiki features.
class role::guidedtour {
    include role::mediawiki
    include role::eventlogging

    @mediawiki::extension { 'GuidedTour': }
}

# == Class: role::gettingstarted
# Configures the GettingStarted extension and its dependencies:
# EventLogging and GuidedTour. GettingStarted adds a special page which
# presents introductory content and tasks to newly-registered editors.
class role::gettingstarted {
    include role::mediawiki
    include role::eventlogging
    include role::guidedtour

    @mediawiki::extension { 'GettingStarted':
        settings => {
            wgGettingStartedRedis => '127.0.0.1',
        },
    }
}

# == Class: role::echo
# Configures Echo, a MediaWiki notification framework.
class role::echo {
    include role::mediawiki
    include role::eventlogging

    @mediawiki::extension { 'Echo':
        needs_update => true,
        settings     => {
            wgEchoEnableEmailBatch => false,
        },
    }
}

# == Class: role::visualeditor
# Provisions the VisualEditor extension, backed by a local
# Parsoid instance.
class role::visualeditor {
    include role::mediawiki

    class { '::mediawiki::parsoid': }
    @mediawiki::extension { 'VisualEditor':
        settings => template('ve-config.php.erb'),
    }
}

# == Class: role::browsertests
# Configures this machine to run the Wikimedia Foundation's set of
# Selenium browser tests for MediaWiki instances.
class role::browsertests {
    include role::mediawiki

    class { '::browsertests': }
}

# == Class: role::umapi
# Configures this machine to run the User Metrics API (UMAPI), a web
# interface for obtaining aggregate measurements of user activity on
# MediaWiki sites.
class role::umapi {
    include role::mediawiki

    class { '::user_metrics': }
}

# == Class: role::uploadwizard
# Configures a MediaWiki instance with UploadWizard, a JavaScript-driven
# wizard interface for uploading multiple files.
class role::uploadwizard {
    include role::mediawiki
    include role::eventlogging
    include role::multimedia

    @mediawiki::extension { [ 'CodeEditor', 'WikiEditor', 'Campaigns' ]: }

    @mediawiki::extension { 'UploadWizard':
        require  => Package['imagemagick'],
        settings => {
            wgEnableUploads       => true,
            wgUseImageMagick      => true,
            wgUploadNavigationUrl => '/wiki/Special:UploadWizard',
            wgUseInstantCommons   => true,
            wgUploadWizardConfig  => {
              altUploadForm       => 'Special:Upload',
              autoCategory        => 'Uploaded with UploadWizard',
              enableChunked       => 'opt-in',
              enableFormData      => true,
              enableMultipleFiles => true,
            },
        },
    }
}


# == Class: role::scribunto
# Configures Scribunto, an extension for embedding scripting languages
# in MediaWiki.
class role::scribunto {
    include role::mediawiki
    include packages::php_luasandbox

    $extras = [ 'CodeEditor', 'WikiEditor', 'SyntaxHighlight_GeSHi' ]
    @mediawiki::extension { $extras: }

    @mediawiki::extension { 'Scribunto':
        settings => {
            wgScribuntoDefaultEngine => 'luasandbox',
            wgScribuntoUseGeSHi      => true,
            wgScribuntoUseCodeEditor => true,
        },
        notify   => Service['apache2'],
        require  => [
            Package['php-luasandbox'],
            Mediawiki::Extension[$extras],
        ],
    }
}

# == Class: role::wikieditor
# Configures WikiEditor, an extension which enable an extendable editing
# toolbar and interface
class role::wikieditor {
    @mediawiki::extension { 'WikiEditor':
        settings => [
            '$wgDefaultUserOptions["usebetatoolbar"] = 1',
            '$wgDefaultUserOptions["usebetatoolbar-cgd"] = 1',
            '$wgDefaultUserOptions["wikieditor-preview"] = 1',
            '$wgDefaultUserOptions["wikieditor-publish"] = 1',
        ],
    }
}

class role::parserfunctions {
    include role::mediawiki

    @mediawiki::extension { 'ParserFunctions': }
}

# == Class: role::proofreadpage
# Configures ProodreadPage, an extension to allow the proofreading of
# a text in comparison with scanned images.
class role::proofreadpage {
    include role::mediawiki
    include role::parserfunctions

    include packages::djvulibre_bin
    include packages::ghostscript
    include packages::netpbm

    php::ini { 'proofreadpage':
        settings => {
            'upload_max_filesize' => '50M',
            'post_max_size' => '50M',
        },
    }

    $extras = [ 'LabeledSectionTransclusion', 'Cite' ]
    @mediawiki::extension { $extras: }

    @mediawiki::extension { 'ProofreadPage':
        needs_update => true,
        settings => [
            '$wgEnableUploads = true',
            '$wgFileExtensions = array_merge( $wgFileExtensions, array(\'pdf\', \'djvu\') )',
            '$wgMaxShellMemory = 300000',
            '$wgDjvuDump = "djvudump"',
            '$wgDjvuRenderer = "ddjvu"',
            '$wgDjvuTxt = "djvutxt"',
            '$wgDjvuPostProcessor = "ppmtojpeg"',
            '$wgDjvuOutputExtension = "jpg"',
        ],
        require  => [
            Package['djvulibre-bin', 'ghostscript', 'netpbm'],
            Mediawiki::Extension[$extras],
        ],
    }
}

# == Class: role::remote_debug
# This class enables support for remote debugging of PHP code using
# Xdebug. Remote debugging allows you to interactively walk through your
# code as executes. Remote debugging is most useful when used in
# conjunction with a PHP IDE such as PhpStorm. The IDE is installed on
# your machine, not the Vagrant VM.
#
# NOTE: This role currently requires that you manually configure
# port forwarding for port 9000. See <http://goo.gl/mx36a>.
class role::remote_debug {
    include php

    php::ini { 'remote_debug':
        settings => {
            'xdebug.idekey'              => 'default',
            'xdebug.remote_autostart'    => '1',
            'xdebug.remote_connect_back' => '1',
            'xdebug.remote_enable'       => '1',
            'xdebug.remote_handler'      => 'dbgp',
            'xdebug.remote_mode'         => 'req',
            'xdebug.remote_port'         => '9000',
        },
        require => Package['php5-xdebug'],
    }
}

# == Class: role::multimedia
# This class configures MediaWiki for multimedia development.
# It is meant to contain general configuration of shared use to other
# extensions that are commonly used by the multimedia team in
# development and testing.
class role::multimedia {
    include role::mediawiki

    include packages::imagemagick

    # Increase PHP upload size from default puny 2MB
    php::ini { 'uploadsize':
        settings => {
            upload_max_filesize => '100M',
            post_max_size       => '100M',
        }
    }

    # Enable dynamic thumbnail generation via the thumb.php
    # script for 404 thumb images.
    @mediawiki::settings { 'thumb.php on 404':
        values => {
            wgThumbnailScriptPath      => false,
            wgGenerateThumbnailOnParse => false,
        },
    }

    @apache::conf { 'thumb.php on 404':
        site    => $mediawiki::wiki_name,
        content => template('thumb_on_404.conf.erb'),
    }
}

# == Class: role::education
# Configures the Education Program extension & its dependencies.
class role::education {
    include role::mediawiki

    @mediawiki::extension { 'cldr':
        priority => 20,
    }

    @mediawiki::extension { 'EducationProgram':
        needs_update => true,
        priority     => 30,    # load *after* CLDR
    }
}

# == Class: role::betafeatures
# Configures the BetaFeatures extension
class role::betafeatures {
    include role::mediawiki

    @mediawiki::extension { 'BetaFeatures':
        priority => 5,  # load before most extensions
    }
}

# == Class: role::pdfhandler
#
# The PdfHandler extension shows uploaded PDF files in a multipage
# preview layout. With the Proofread Page extension enabled, PDFs can be
# displayed side-by-side with text for transcribing books and other
# documents, as is commonly done with DjVu files (particularly in
# Wikisource).
class role::pdfhandler {
    include role::multimedia

    include packages::ghostscript
    include packages::poppler_utils
    include packages::imagemagick

    @mediawiki::extension { 'PdfHandler':
        needs_update => true,
        require      => Package['ghostscript', 'imagemagick', 'poppler-utils'],
        settings     => [
            '$wgEnableUploads = true',
            '$wgMaxShellMemory = 300000',
            '$wgFileExtensions[] = \'pdf\'',
        ],
    }
}

# == Class: role::math
#
# The Math extension provides support for rendering mathematical formulas
# on-wiki via texvc.
class role::math {
    include role::mediawiki

    include packages::mediawiki_math
    include packages::ocaml_native_compilers

    @mediawiki::extension { 'Math':
        needs_update => true,
    }

    exec { 'compile texvc':
        command => 'make',
        cwd     => "/vagrant/mediawiki/extensions/Math/math",
        creates => "/vagrant/mediawiki/extensions/Math/math/texvc",
        require => [
          Package['mediawiki-math', 'ocaml-native-compilers'],
          Mediawiki::Extension['Math'],
        ],
    }
}
