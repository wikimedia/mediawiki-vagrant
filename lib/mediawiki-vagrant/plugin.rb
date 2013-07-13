class MediaWikiVagrant < Vagrant.plugin('2')
    name 'MediaWiki Vagrant'

    command 'paste-puppet' do
        require 'mediawiki-vagrant/commands/paste-puppet'
        PastePuppet
    end
end
