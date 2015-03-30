# == Class: role::warnings_as_errors
# Turns all PHP warnings and notices into errors, useful for testing
class role::warnings_as_errors {
    mediawiki::settings { 'warnings_as_errors':
        values => template( 'role/warnings_as_errors/conf.php.erb' ),
    }
}
