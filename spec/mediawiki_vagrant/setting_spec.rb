require 'spec_helper'
require 'mediawiki-vagrant/setting'

module MediaWikiVagrant
  describe Setting do
    let(:setting) { Setting.new(name, value) }

    let(:name) { :foo }
    let(:value) { nil }

    describe '#set?' do
      subject { setting.set? }

      context 'when its value is nil' do
        let(:value) { nil }

        it { is_expected.to be(false) }
      end

      context 'when its value is not nil' do
        let(:value) { :bar }

        it { is_expected.to be(true) }
      end
    end

    describe '#unset!' do
      subject { setting.unset! }

      let(:value) { :bar }

      it 'sets the value to nil' do
        subject
        expect(setting.value).to be(nil)
      end
    end

    describe '#value' do
      subject { setting.value }

      context 'where the value is nil' do
        let(:value) { nil }

        context 'and the setting has no default' do
          it { is_expected.to be(nil) }
        end

        context 'but the setting has a default' do
          before { setting.default = :bar }

          it 'returns the default' do
            expect(subject).to be(:bar)
          end
        end
      end
    end

    describe '#value=' do
      subject { setting.value = new_value }

      let(:new_value) { 10 }

      context 'where there is no coersion' do
        it 'should use the given value' do
          subject
          expect(setting.value).to be(new_value)
        end
      end

      context 'where there is a coersion' do
        let(:coercion) { ->(_, new) { new * 2 } }

        before { setting.coercion = coercion }

        it 'calls the coercion with the setting and the given value' do
          expect(coercion).to receive(:call).with(setting, new_value)
          subject
        end

        it 'uses the result of the coercion for the new value' do
          subject
          expect(setting.value).to eq(20)
        end
      end
    end
  end
end
