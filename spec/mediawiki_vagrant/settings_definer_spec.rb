require 'spec_helper'
require 'mediawiki-vagrant/settings_definer'

module MediaWikiVagrant
  describe SettingsDefiner do
    let(:settings_class) { Class.new { include SettingsDefiner } }

    describe '.definitions' do
      subject { settings_class.definitions }

      it { is_expected.to be_a(Hash) }

      context 'when settings have been defined' do
        let(:foo_setting) do
          settings_class.setting :foo,
            description: 'foo setting',
            help: 'help with foo'
        end

        before { foo_setting }

        it 'returns a hash of the defined settings' do
          expect(subject).to be_a(Hash)
          expect(subject).to include(:foo)
        end

        it 'copies each setting to prevent changes to global state' do
          expect(subject[:foo]).to be_a(Setting)
          expect(subject[:foo]).not_to be(foo_setting)
          expect(subject[:foo].description).to eq('foo setting')
          expect(subject[:foo].help).to eq('help with foo')
        end
      end
    end
  end
end
