# == Class: role::confirmedit
# The ConfirmEdit extension lets you use various different CAPTCHA
# techniques, to try to prevent spambots and other automated tools from
# editing your wiki, as well as to foil automated login attempts that try
# to guess passwords.
class role::confirmedit {
    include role::mediawiki

    require_package('fonts-dejavu')
    require_package('python-imaging')
    require_package('wbritish-small')

    $font     = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    $wordlist = '/usr/share/dict/words'
    $output   = "${::role::mediawiki::dir}/images/temp/captcha"
    $key      = 'FOO'

    mediawiki::extension { 'ConfirmEdit':
        notify => Exec['generate_captchas'],
    }

    mediawiki::settings { 'ConfirmEdit FancyCaptcha':
        header => 'require_once "$IP/extensions/ConfirmEdit/FancyCaptcha.php";',
        values => {
            wgCaptchaClass           => 'FancyCaptcha',
            wgCaptchaDirectory       => '$IP/images/temp/captcha',
            wgCaptchaDirectoryLevels => 0,
            wgCaptchaSecret          => $key,
        },
    }

    file { [ "${::role::mediawiki::dir}/images/temp", $output ]:
        ensure => directory,
        before => Exec['generate_captchas'],
    }

    exec { 'generate_captchas':
        command     => "python captcha.py --font=${font} --wordlist=${wordlist} --key=${key} --output=${output}",
        cwd         => "${::role::mediawiki::dir}/extensions/ConfirmEdit",
        require     => Package['wbritish-small', 'fonts-dejavu'],
        refreshonly => true,
    }
}
