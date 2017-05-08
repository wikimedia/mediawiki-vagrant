# == Class: role::codemirror
# The CodeMirror extension extension provides syntax highlighting in WikiEditor and VisualEditor's
# wikitext mode.
class role::codemirror {
    include ::role::wikieditor
    include ::role::visualeditor

    mediawiki::extension { 'CodeMirror': }
}
