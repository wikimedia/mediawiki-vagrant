# == Class: phpmailer
#
# Wikimedia redistribution of the https://github.com/PHPMailer/PHPMailer
# email sending library.
#
# === Parameters
#
# [*dir*]
#   Root directory for the package
#
class phpmailer(
    $dir,
) {
    git::clone { 'wikimedia/fundraising/phpmailer':
        directory => $dir,
    }
}
