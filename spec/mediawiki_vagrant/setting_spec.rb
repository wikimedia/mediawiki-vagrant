require 'spec_helper'
require 'mediawiki-vagrant/setting'

module MediaWikiVagrant
  describe Setting do
    let(:setting) { Setting.new(name, value) }

    let(:name) { :foo }
    let(:value) { nil }

    describe '#auto!' do
      subject { setting.auto! }

      context 'where `auto=` is set' do
        before { setting.auto = -> { :bar } }

        context 'and no value is set' do
          it 'sets the value using the auto result' do
            subject
            expect(setting.value).to eq(:bar)
          end
        end

        context 'but a value is set' do
          let(:value) { :baz }

          it 'sets the value using the auto result' do
            subject
            expect(setting.value).to eq(:baz)
          end
        end
      end

      context 'where `auto=` is not set' do
        context 'and no value is set' do
          it 'the value remains unset' do
            subject
            expect(setting).not_to be_set
          end
        end
      end
    end

    describe '#combine!' do
      subject { setting.combine!(other) }

      let(:value) { 1 }
      let(:other) { 2 }

      it 'defaults to simply taking the other value' do
        expect(setting).to receive(:value=).with(2)
        subject
      end

      context 'where a combiner is defined' do
        before { setting.combiner = ->(setting, new) { setting.value + new } }

        it 'uses it to get the new value' do
          expect(setting).to receive(:value=).with(3)
          subject
        end
      end
    end

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

      context 'given a value of "auto"' do
        let(:new_value) { 'auto' }

        context 'where an auto configuration is defined' do
          let(:auto) { -> { 15 } }

          before { setting.auto = auto }

          it 'calls the auto configuration' do
            subject
            expect(setting.value).to eq(15)
          end
        end

        context 'where an auto configuration is not defined' do
          it 'sets the value as literally "auto"' do
            subject
            expect(setting.value).to eq('auto')
          end
        end
      end
    end
  end
end
