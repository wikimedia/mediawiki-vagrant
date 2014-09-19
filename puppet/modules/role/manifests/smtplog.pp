# == Class: role::smtplog
#
# Provisions a python service that will listen on port 25 for SMTP connections
# and log the messages delivered to a file. This is useful for debugging email
# output from various applications without worrying about actually sending
# emails to the outside world.
#
class role::smtplog {
    include ::smtplog
}
