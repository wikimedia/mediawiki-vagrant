# == Function: get_clusters
#
# Given a selector hash, which can contain a cluster selector and/or
# a site selector, this function will return a data
# structure that contains all nodes clustered by cluster/site.
#
# === Parameters
# [*selector*] An hash used to select the cluster and/or sites, if present;
#              allowed keys are 'site' and 'cluster', and should both be lists
#              of clusters and sites to select.
#
# === Examples
#
# # Return all nodes known to puppetDB
# $nodes = get_clusters()
#
# # All eqiad nodes grouped by cluster/site
# $eqiad_nodes = get_clusters({'site' => ['eqiad']})
#
# # All MediaWiki appserver and api nodes
# $mw_servers = get_clusters({'cluster' => ['appserver', 'appserver_api'})
#
Puppet::Functions.create_function(:get_clusters) do
  dispatch :get_clusters do
    optional_param 'Hash', :selector
  end

  def get_clusters(selector = {})
    all = {}
    # Ganglia config is the source of truth about clusters/site
    cluster_config = call_function('hiera', 'ganglia_clusters', {})

    clusters = selector.include?('cluster') ? selector['cluster'] : cluster_config.keys
    sites = selector.include?('site') ? selector['site'] : false

    call_function('query_resources', false, 'Class["Profile::Cumin::Target"]', false, 'certname asc').each do |node|
      cluster = node['parameters']['cluster']
      site = node['parameters']['site']
      fqdn = node['certname']
      next unless clusters.include?(cluster)
      next if sites && !sites.include?(site)
      all[cluster] ||= {}
      all[cluster][site] ||= []
      all[cluster][site] << fqdn
    end
    all
  end
end
