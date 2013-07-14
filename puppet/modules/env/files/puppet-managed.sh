if [ -d /etc/profile.d/puppet-managed ]; then
  for i in /etc/profile.d/puppet-managed/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
