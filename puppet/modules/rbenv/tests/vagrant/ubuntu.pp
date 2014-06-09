class { 'rbenv': group => $group }

rbenv::plugin { 'sstephenson/ruby-build': }
rbenv::plugin { 'sstephenson/rbenv-vars': }

package { ['libxslt1-dev', 'libxml2-dev']: }->
rbenv::build { '2.0.0-p353': global => true }

rbenv::gem { 'backup':
  version      => '3.9.0',
  ruby_version => '2.0.0-p353',
  skip_docs    => true,
}
