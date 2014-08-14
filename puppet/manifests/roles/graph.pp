# == Class: role::graph
# Configures Graph extension
class role::graph {
    include role::mediawiki
    include role::jsonconfig

    mediawiki::extension { 'Graph':
        settings => [
            '$wgEnableGraphParserTag = true',
            '$wgJsonConfigModels["Graph.JsonConfig"] = "graph\Content"',
            '$wgJsonConfigs["Graph.JsonConfig"] = array(
               "namespace" => 484,
               "nsName" => "Graph",
               "isLocal" => true,
            );',
        ],
    }
}
