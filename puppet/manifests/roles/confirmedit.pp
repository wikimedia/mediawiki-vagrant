# == Class: role::confirmedit
# The ConfirmEdit extension lets you use various different CAPTCHA
# techniques, to try to prevent spambots and other automated tools from
# editing your wiki, as well as to foil automated login attempts that try
# to guess passwords.
class role::confirmedit {
    include role::mediawiki
    include python::pil

    mediawiki::extension { 'ConfirmEdit':
		before => Exec['generate FancyCaptcha images']
	}

    mediawiki::settings { 'ConfirmEdit FancyCaptcha':
        values => {
            wgCaptchaClass => 'FancyCaptcha',
            wgCaptchaDirectory => '$IP/images/temp/captcha',
            wgCaptchaDirectoryLevels => 0,
            wgCaptchaSecret => 'FOO',
        },
        header => 'require_once "$IP/extensions/ConfirmEdit/FancyCaptcha.php";',
    }

    exec { 'generate FancyCaptcha images':
        command => 'echo "hello\nworld\n" > /tmp/words; mkdir -p ../../images/temp/captcha; python captcha.py --font=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf --wordlist=/tmp/words --key=FOO --output=../../images/temp/captcha --count=2',
        cwd     => '/vagrant/mediawiki/extensions/ConfirmEdit',
    }
}
