# == Class: role::confirmedit
# The ConfirmEdit extension lets you use various different CAPTCHA
# techniques, to try to prevent spambots and other automated tools from
# editing your wiki, as well as to foil automated login attempts that try
# to guess passwords.
class role::confirmedit {
    require ::role::mediawiki

    require_package('fonts-dejavu')
    require_package('python-imaging')
    require_package('wbritish-small')

    $font     = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    $wordlist = '/usr/share/dict/words'
    $output   = "${::mediawiki::dir}/images/temp/captcha"
    $key      = 'FOO'

    mediawiki::extension { 'ConfirmEdit':
        settings => [
          # Skip captcha for users with confirmed emails
          '$wgGroupPermissions["emailconfirmed"]["skipcaptcha"] = true;',
          '$wgAllowConfirmedEmail = true;',
        ],
    }

    mediawiki::settings { 'ConfirmEdit FancyCaptcha':
        header   => 'wfLoadExtension( "ConfirmEdit/FancyCaptcha" ); $wmvActiveExtensions[] = "FancyCaptcha";',
        values   => {
            wgCaptchaClass           => 'FancyCaptcha',
            wgCaptchaDirectory       => '$IP/images/temp/captcha',
            wgCaptchaDirectoryLevels => 0,
            wgCaptchaSecret          => $key,
        },
        priority => 11,
        require  => MediaWiki::Extension['ConfirmEdit'],
        notify   => Exec['generate_captchas'],
    }

    file { [ "${::mediawiki::dir}/images/temp", $output ]:
        ensure  => directory,
        before  => Exec['generate_captchas'],
        require => Git::Clone['mediawiki/core'],
    }

    exec { 'generate_captchas':
        command     => "/usr/bin/python captcha.py --font=${font} --wordlist=${wordlist} --key=${key} --output=${output}",
        cwd         => "${::mediawiki::dir}/extensions/ConfirmEdit",
        require     => [
            Package['wbritish-small'],
            Package['fonts-dejavu'],
        ],
        refreshonly => true,
    }
}
