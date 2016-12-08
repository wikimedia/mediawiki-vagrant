# A Facter plugin that returns the Elasticsearch version the next apt run will upgrade to.

require 'facter'

Facter.add(:elasticsearch_version) do
  setcode do
    policy = Facter::Util::Resolution.exec('apt-cache policy elasticsearch')
    m = /^ *Candidate: (\S+)$/.match(policy)
    m && m[1]
  end
end
