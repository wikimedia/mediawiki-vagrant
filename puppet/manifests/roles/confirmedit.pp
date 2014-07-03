# == Class: role::confirmedit
# The ConfirmEdit extension lets you use various different CAPTCHA
# techniques, to try to prevent spambots and other automated tools from
# editing your wiki, as well as to foil automated login attempts that try
# to guess passwords.
class role::confirmedit {
    include role::mediawiki
    include packages::fonts_dejavu
    include packages::pil
    include packages::wbritish_small

    $font     = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    $wordlist = '/usr/share/dict/words'
    $output   = "${::role::mediawiki::dir}/images/temp/captcha"
    $key      = 'FOO'

    mediawiki::extension { 'ConfirmEdit':
        notify => Exec['generate FancyCaptcha images'],
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
        before => Exec['generate FancyCaptcha images'],
    }

    exec { 'generate FancyCaptcha images':
        cwd         => "${::role::mediawiki::dir}/extensions/ConfirmEdit",
        require     => Package['wbritish-small', 'fonts-dejavu'],
        command     => "/usr/bin/python captcha.py --font=${font} --wordlist=${wordlist} --key=${key} --output=${output}",
        refreshonly => true,
    }
}
