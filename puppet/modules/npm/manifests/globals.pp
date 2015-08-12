# == Class: npm::globals
#
# Installs some commonly used NPM modules globally.
#
class npm::globals {
    npm::global { ['mocha', 'grunt', 'node-gyp', 'node-pre-gyp']: }
}
