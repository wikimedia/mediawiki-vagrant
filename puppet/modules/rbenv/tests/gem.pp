package { ['git', 'build-essential']: ensure => 'installed' }->
class { 'rbenv': }->
rbenv::plugin { 'sstephenson/ruby-build': }->
rbenv::build { '2.0.0-p247': global => true }->
rbenv::gem { 'thor':
  version      => '0.18.1',
  ruby_version => '2.0.0-p247'
}
