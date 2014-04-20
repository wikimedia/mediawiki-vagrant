# == Class: role::confirmedit
# The ConfirmEdit extension lets you use various different CAPTCHA
# techniques, to try to prevent spambots and other automated tools from
# editing your wiki, as well as to foil automated login attempts that try
# to guess passwords.
class role::confirmedit {
    include role::mediawiki

    mediawiki::extension { 'ConfirmEdit':
        settings => { wgCaptchaClass => 'SimpleCaptcha' },
    }
}
