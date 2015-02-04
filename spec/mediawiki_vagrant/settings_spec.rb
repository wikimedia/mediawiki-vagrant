require 'spec_helper'
require 'mediawiki-vagrant/settings'

module MediaWikiVagrant
  describe Settings do
    include SpecHelpers::MockEnvironment

    let(:settings) { Settings.new }

    let(:definitions) { { foo: Setting.new(:foo, 'x') } }
    before { allow(Settings).to receive(:definitions).and_return(definitions) }

    describe '#initialize' do
      subject { settings }

      it 'contains the defined settings' do
        expect(subject[:foo]).to eq('x')
      end

      context 'where no settings are defined' do
        let(:definitions) { {} }

        it 'contains no settings' do
          expect(subject.setting(:foo)).to be_nil
        end
      end
    end

    describe '#[]' do
      subject { settings[key] }

      context 'given a key for an existing setting' do
        let(:key) { :foo }

        it 'returns the setting' do
          expect(subject).to eq('x')
        end

        context 'where the key is abnormal' do
          let(:key) { 'FOO' }

          it 'still returns the right setting' do
            expect(subject).to eq('x')
          end
        end
      end

      context 'given a key for a non-existent setting' do
        let(:key) { :bar }

        it { is_expected.to be(nil) }
      end
    end

    describe '#[]=' do
      subject { settings[key] = value }

      let(:value) { 'y' }

      context 'given a key for an existing setting' do
        let(:key) { :foo }

        it 'modifies the setting value' do
          expect(settings.setting(:foo)).to receive(:value=).with(value)
          subject
        end
      end

      context 'given a key for a non-existent setting' do
        let(:key) { :bar }

        it 'creates a new setting' do
          new_setting = double(Setting)
          expect(Setting).to receive(:new).with(:bar, value).and_return(new_setting)

          subject
          expect(settings.setting(:bar)).to be(new_setting)
        end
      end
    end

    describe '#each' do
      subject { settings.each }

      it { is_expected.to be_an(Enumerator) }

      context 'with a given block' do
        it 'iterates over the settings using the block' do
          expect { |block| settings.each(&block) }.to yield_control

          settings.each do |(key, setting)|
            expect(key).to be(:foo)
            expect(setting).to be_a(Setting)
          end
        end
      end
    end

    describe '#load', :fakefs do
      subject { settings.load(path_or_io) }

      context 'given a path to a file' do
        let(:path_or_io) { '/example/settings.yaml' }

        before { mock_file(path_or_io, content: 'foo: y') }

        it 'opens the given file and updates the settings' do
          expect(settings).to receive(:update).with('foo' => 'y')
          subject
        end
      end

      context 'given a path to a directory' do
        let(:path_or_io) { '/example' }

        before do
          mock_files_in(
            path_or_io,
            'settings1.yaml' => 'foo: y',
            'settings2.yaml' => 'bar: z'
          )
        end

        it 'opens each .yaml file in the given directory and updates the settings' do
          expect(settings).to receive(:update).with('foo' => 'y')
          expect(settings).to receive(:update).with('bar' => 'z')
          subject
        end
      end

      context 'given an IO object' do
        let(:path_or_io) { StringIO.new('foo: y') }

        it 'reads it and updates the settings' do
          expect(settings).to receive(:update).with('foo' => 'y')
          subject
        end
      end
    end

    describe '#required' do
      subject { settings.required }

      let(:definitions) { { foo: Setting.new(:foo), bar: Setting.new(:bar) } }

      before { definitions[:bar].default = 'x' }

      it 'returns settings that have no default value' do
        expect(subject).to include([:foo, settings.setting(:foo)])
        expect(subject).not_to include([:bar, settings.setting(:bar)])
      end
    end

    describe '#save', :fakefs do
      subject { settings.save(path_or_io) }

      context 'given a path' do
        let(:path_or_io) { '/example/settings.yaml' }

        before { mock_directory('/example') }

        it 'writes the settings as YAML to the given path' do
          subject
          expect(File.read(path_or_io)).to eq(align(<<-end))
            ---
            foo: x
          end
        end
      end

      context 'given an IO' do
        let(:path_or_io) { StringIO.new }

        it 'writes the settings as YAML' do
          subject
          path_or_io.rewind
          expect(path_or_io.read).to eq(align(<<-end))
            ---
            foo: x
          end
        end
      end
    end

    describe '#setting' do
      subject { settings.setting(key) }

      context 'where the setting exists' do
        let(:key) { :foo }

        it 'returns the corresponding setting object' do
          expect(subject).to be_a(Setting)
        end
      end

      context 'where the setting does not exist' do
        let(:key) { :bar }

        it { is_expected.to be(nil) }
      end
    end

    describe '#update' do
      subject { settings.update(hash) }

      context 'given a hash' do
        let(:hash) { { foo: 'y', bar: 'z' } }

        it 'updates the settings and returns self' do
          expect(subject[:foo]).to eq('y')
          expect(subject[:bar]).to eq('z')
          expect(subject).to be(settings)
        end
      end

      context 'given something else' do
        let(:hash) { double('something') }

        it 'does nothing and returns self' do
          expect(subject).to be(settings)
        end
      end
    end

    describe '#unset!' do
      subject { settings.unset!(key) }

      let(:key) { :foo }

      it 'unsets the given setting' do
        expect(settings.setting(:foo)).to receive(:unset!)
        subject
      end
    end
  end
end
