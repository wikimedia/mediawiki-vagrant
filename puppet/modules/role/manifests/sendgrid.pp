# == Class: role::sendgrid
#
# This role provisions the SendGrid extension, which allows users to
# use the SendGrid API to send emails on-wiki using a valid API key
#
class role::sendgrid {
    mediawiki::extension { 'SendGrid':
        composer => true,
    }
}