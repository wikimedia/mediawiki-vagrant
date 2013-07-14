class MediaWikiVagrant < Vagrant.plugin('2')
    name 'MediaWiki-Vagrant'

    command 'paste-puppet' do
        require 'mediawiki-vagrant/commands/paste-puppet'
        PastePuppet
    end

    command 'run-tests' do
        require 'mediawiki-vagrant/commands/run-tests'
        RunTests
    end
end
