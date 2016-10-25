# == Class: role::fundraising
#
# Provision subsystems being developed by the Fundraising group
#
class role::fundraising {
    include ::role::centralnotice
    include ::role::payments
    include ::redis
    include ::crm
    include ::rsyslog
    include ::smashpig
}
