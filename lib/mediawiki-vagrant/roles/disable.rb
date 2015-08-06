require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/roles/change'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  module Roles
    class Disable < Change
      def self.synopsis
        'disables a mediawiki-vagrant role'
      end

      private

      def banner
        'Disable one or more optional roles.'
      end

      def new_roles(given_roles)
        @mwv.roles_enabled - given_roles
      end

      def possible_roles
        @mwv.roles_enabled
      end

      def role_error(role)
        "'#{role}' is not currently enabled."
      end
    end
  end
end
