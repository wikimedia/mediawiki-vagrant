class { 'rbenv': }->
rbenv::plugin { 'sstephenson/ruby-build': }->
rbenv::build { '2.0.0-p247': global => true }
