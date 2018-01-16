Test suite for /puppet
----------------------

    bundle install
    bundle exec rake spec

It uses rspec under the hood, you can pass it options via SPEC_OPTS:

  SPEC_OPTS=--help bundle exec rake spec

Some examples:

Filter by example name:

  SPEC_OPTS="-e role::wikitech"

Only run tests that previously failed:

  SPEC_OPTS="--only-failures"

Run next failure:

  SPEC_OPTS="--next-failure"

The spec status are stored in /puppet/rspec_status
