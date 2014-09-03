# == Class: role::graph
# Configures Graph extension
class role::graph {
    include ::role::jsonconfig

    mediawiki::extension { 'Graph':
        settings => [
            '$wgEnableGraphParserTag = true',
            '$wgGraphDataDomains = array("localhost","127.0.0.1")',
            '$wgJsonConfigModels["Graph.JsonConfig"] = \'graph\Content\'',
            '$wgJsonConfigs["Graph.JsonConfig"] = array(
               "namespace" => 484,
               "nsName" => "Graph",
               "isLocal" => true,
            );',
        ],
    }
}
