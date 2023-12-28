# == Class: role::adiutor
# Sets up the Adiutor[https://www.mediawiki.org/wiki/Extension:Adiutor]
# MediaWiki extension, a UI for moderation, triage, and content maintenance
# tasks.
#
class role::adiutor {
    mediawiki::extension { 'Adiutor':
    }
}
