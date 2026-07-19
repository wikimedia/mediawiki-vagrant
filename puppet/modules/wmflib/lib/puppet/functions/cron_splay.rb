# cron_splay.rb
#
# Given an array of fqdn which a cron is applicable to, and a period arg which is
# one of 'hourly', 'daily', or 'weekly', this sorts the fqdn set with
# per-datacenter interleaving for DC-numbered hosts, splays them to fixed even
# intervals within the total period, and then outputs a set of crontab time
# fields for the fqdn currently being compiled-for.
#
# The idea here is to ensure each host in the set executes the cron once per time
# period, and also ensure the time between hosts is consistent (no edge cases
# much closer than the average) by splaying them as evenly as possible with
# rounding errors.  For the case of hosts with NNNN numbers indicating the
# datacenter in the first digit, we also maximize the period between any two
# hosts in a given datacenter by interleaving sorted per-DC lists of hosts before
# splaying.
#
# The third and final argument is a static seed which modulates the splayed
# values in two different ways to minimize the effects of multiple cron_splay()
# with the same hostlist and period.  It is used to select a determinstically
# random "offset" for the splayed time values (so that the first host doesn't
# always start at 00:00), and is also used to permute the order of the hosts
# within each DC uniquely.
#
# *Examples:*
#
#     $times = fqdn_splay($hosts, 'weekly', 'foo-static-seed')
#     cron { 'foo':
#         minute   => $times['minute'],
#         hour     => $times['hour'],
#         weekday  => $times['weekday'],
#     }
#
require 'digest/md5'

Puppet::Functions.create_function(:cron_splay) do
  dispatch :cron_splay do
    param 'Array', :hosts
    param 'String', :period
    param 'String', :seed
  end

  def cron_splay(hosts, period, seed)
    mins = case period
           when 'hourly' then 60
           when 'daily' then 1440
           when 'weekly' then 10080
           else raise(Puppet::ParseError, 'cron_splay(): invalid period')
           end

    # Avoid this edge case for now.  At sufficiently large host counts and
    # small period, randomization is probably better anyways.
    if hosts.length > mins
      raise(Puppet::ParseError, 'cron_splay(): too many hosts for period')
    end

    # split hosts into N lists based the first digit of /NNNN/, defaulting to zero
    sublists = Array.new(10) { [] }
    hosts.each do |h|
      match = /([1-9])[0-9]{3}/.match(h)
      if match
        sublists[match[1].to_i].push(h)
      else
        sublists[0].push(h)
      end
    end

    # sort each sublist into a determinstic order based on seed
    sublists.each { |s| s.sort_by! { |x| Digest::MD5.hexdigest(seed + x) } }

    # interleave sublists into "ordered"
    longest = sublists.max_by(&:length)
    sublists -= [longest]
    ordered = longest.zip(*sublists).flatten.compact

    # find the index of this host in ordered
    this_idx = ordered.index(closure_scope.lookupvar('::fqdn'))
    if this_idx.nil?
      raise(Puppet::ParseError, 'cron_splay(): this host not in set')
    end

    # find the truncated-integer splayed value of this host
    tval = this_idx * mins / ordered.length

    # use the seed (again) to add a time offset to the splayed values,
    # the time offset never being larger than the splayed interval
    tval += Digest::MD5.hexdigest(seed).to_i(16) % (mins / ordered.length)

    # generate the output
    output = {}
    output['minute'] = tval % 60
    output['hour'] = period == 'hourly' ? '*' : (tval / 60) % 24
    output['weekday'] = period == 'weekly' ? tval / 1440 : '*'

    output
  end
end

# vim: set ts=2 sw=2 et :
