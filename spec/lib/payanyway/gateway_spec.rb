describe Payanyway::Gateway do
  describe '#payment_url' do
    let(:use_signature) { false }
    subject { described_class.payment_url(params, use_signature) }

    context 'when min params' do
      let(:params) { { amount: '120.25', transaction_id: 'FF790ABCD' } }

      it { is_expected.to eq('https://demo.moneta.ru/assistant.htm?MNT_ID=141290&MNT_CURRENCY_CODE=RUB&MNT_TEST_MODE=1&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD') }
      it { is_expected.to_not be_include('MNT_SIGNATURE') }
    end

    context 'when have custom params' do
      let(:params) { { amount: '120.25', transaction_id: 'FF790ABCD', custom1: 'utm_source' } }

      it { is_expected.to eq('https://demo.moneta.ru/assistant.htm?MNT_ID=141290&MNT_CURRENCY_CODE=RUB&MNT_TEST_MODE=1&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD&MNT_CUSTOM1=utm_source') }
    end

    context 'when use_signature == true' do
      let(:use_signature) { true }
      let(:params) { { amount: '120.25', transaction_id: 'FF790ABCD' } }

      it { is_expected.to be_include('MNT_SIGNATURE') }
    end

    context 'when moneta_id is override' do
      let(:params) { { amount: '120.25', transaction_id: 'FF790ABCD', moneta_id: '54321' } }

      it { is_expected.to eq('https://demo.moneta.ru/assistant.htm?MNT_ID=54321&MNT_CURRENCY_CODE=RUB&MNT_TEST_MODE=1&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD') }
    end
  end
end
