# == Class: role::articlecreationworkflow
# The ArticleCreationWorkflow[https://www.mediawiki.org/wiki/Extension:ArticleCreationWorkflow]
# allows to customize page creation experience for new users.
#
class role::articlecreationworkflow {
  mediawiki::extension { 'ArticleCreationWorkflow':
      priority => $::load_early, # Must load before VisualEditor
  }
}
