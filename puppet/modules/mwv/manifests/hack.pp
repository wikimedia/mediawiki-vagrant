# == Class: mwv::hack
#
# FIXME bandaid for T292324 until upgrading to buster: remove the
# DST X3 root cert to avoid old openssl/gnutls erroring out for
# Let's Encrypt certs.
#
class mwv::hack {
    exec { 'disable broken letsencrypt cert':
        command => 'sed -i \'/^mozilla\/DST_Root_CA_X3/s/^/!/\' /etc/ca-certificates.conf && sudo update-ca-certificates',
        onlyif  => 'grep \'^mozilla/DST_Root_CA_X3\' /etc/ca-certificates.conf',
    }
}
