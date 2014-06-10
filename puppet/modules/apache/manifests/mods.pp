# == Class: apache::mods
#
# This module contains unparametrized classes that wrap some popular
# Apache mods. Because the classes are not parametrized, they may be
# included multiple times without causing duplicate definition errors.
#

# Modules that are bundled with the apache2 package
class apache::mods::actions       { apache::mod { 'actions':       } }
class apache::mods::alias         { apache::mod { 'alias':         } }
class apache::mods::authnz_ldap   { apache::mod { 'authnz_ldap':   } }
class apache::mods::dav           { apache::mod { 'dav':           } }
class apache::mods::dav_fs        { apache::mod { 'dav_fs':        } }
class apache::mods::headers       { apache::mod { 'headers':       } }
class apache::mods::proxy_http    { apache::mod { 'proxy_http':    } }
class apache::mods::rewrite       { apache::mod { 'rewrite':       } }
class apache::mods::userdir       { apache::mod { 'userdir':       } }

# Modules that depend on additional packages
class apache::mods::fastcgi       { apache::mod { 'fastcgi':     } <- package { 'libapache2-mod-fastcgi':   } }
class apache::mods::fcgid         { apache::mod { 'fcgid':       } <- package { 'libapache2-mod-fcgid':     } }
class apache::mods::passenger     { apache::mod { 'passenger':   } <- package { 'libapache2-mod-passenger': } }
class apache::mods::perl2         { apache::mod { 'perl2':       } <- package { 'libapache2-mod-perl2':     } }
class apache::mods::php5          { apache::mod { 'php5':        } <- package { 'libapache2-mod-php5':      } }
class apache::mods::proxy         { apache::mod { 'proxy':       } <- package { 'libapache2-mod-proxy':     } }
class apache::mods::python        { apache::mod { 'python':      } <- package { 'libapache2-mod-python':    } }
class apache::mods::rpaf          { apache::mod { 'rpaf':        } <- package { 'libapache2-mod-rpaf':      } }
class apache::mods::ssl           { apache::mod { 'ssl':         } <- package { 'libapache2-mod-ssl':       } }
class apache::mods::uwsgi         { apache::mod { 'uwsgi':       } <- package { 'libapache2-mod-uwsgi':     } }
class apache::mods::wsgi          { apache::mod { 'wsgi':        } <- package { 'libapache2-mod-wsgi':      } }

# Modules that target a specific distribution
class apache::mods::access_compat { if versioncmp($::lsbdistrelease, '13') > 0 { apache::mod { 'access_compat': } } }  # on <13, not relevant
class apache::mods::version       { if versioncmp($::lsbdistrelease, '13') < 0 { apache::mod { 'version':       } } }  # on >13, baked-in
