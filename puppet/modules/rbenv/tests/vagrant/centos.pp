class { 'rbenv': group => $group }

rbenv::plugin { 'sstephenson/ruby-build': }
rbenv::plugin { 'sstephenson/rbenv-vars': }
rbenv::build { '2.0.0-p353': global => true }

rbenv::gem { 'rack':
  ruby_version => '2.0.0-p353',
  skip_docs    => true,
}
