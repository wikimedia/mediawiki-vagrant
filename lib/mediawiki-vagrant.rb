require 'mediawiki-vagrant/helpers'

module MediaWikiVagrant
    class Plugin < Vagrant.plugin('2')
        name 'MediaWiki-Vagrant'

        command 'paste-puppet' do
            require 'mediawiki-vagrant/paste-puppet'
            PastePuppet
        end

        command 'run-tests' do
            require 'mediawiki-vagrant/run-tests'
            RunTests
        end

        command 'list-roles' do
            require 'mediawiki-vagrant/roles'
            ListRoles
        end

        command 'reset-roles' do
            require 'mediawiki-vagrant/roles'
            ResetRoles
        end

        command 'enable-role' do
            require 'mediawiki-vagrant/roles'
            EnableRole
        end

        command 'disable-role' do
            require 'mediawiki-vagrant/roles'
            DisableRole
        end

        action_hook(self::ALL_ACTIONS) do |hook|
            require 'mediawiki-vagrant/middleware'
            hook.before(Vagrant::Action::Builtin::Provision, Middleware)
        end

    end
end
