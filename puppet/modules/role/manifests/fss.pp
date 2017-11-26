# == Class: roles::fss
#
# FastStringSearch is a PHP extension for fast string search and replace. It is
# used by StringUtils.php. It supports multiple search terms. It is used as a
# replacement for PHP's strtr, which is extremely slow in certain cases.
# Chinese script conversion is one of those cases. This extension uses a
# Commentz-Walter style algorithm for multiple search terms, or a Boyer-Moore
# algorithm for single search terms.
#
# Only needed for php-based wikis
class role::fss {
    require_package('php-fss')
}
