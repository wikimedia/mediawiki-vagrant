# == Class: npm::globals
#
# Installs some commonly used NPM modules globally.
#
class npm::globals {
    npm::global { ['mocha', 'grunt-cli', 'node-gyp', 'node-pre-gyp']: }
}
