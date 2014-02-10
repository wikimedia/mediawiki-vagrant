# == Class: role::codeeditor
# The CodeEditor extension embeds the ACE code editor in the WikiEditor
# edit interface when source code content.
class role::codeeditor {
    include role::mediawiki
    include role::wikieditor

    mediawiki::extension { 'CodeEditor': }
}
