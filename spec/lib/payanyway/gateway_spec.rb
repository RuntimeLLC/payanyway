describe Payanyway::Gateway do
  describe '#payment_url' do
    subject { described_class.payment_url(params) }

    context 'when min params' do
      let(:params) { { amount: '120.25', order_id: 'FF790ABCD' } }

      it { is_expected.to eq('https://demo.moneta.ru/assistant.htm?MNT_ID=141290&MNT_CURRENCY_CODE=RUB&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD') }
    end

    context 'when have custom params' do
      let(:params) { { amount: '120.25', order_id: 'FF790ABCD', custom1: 'utm_source' } }

      it { is_expected.to eq('https://demo.moneta.ru/assistant.htm?MNT_ID=141290&MNT_CURRENCY_CODE=RUB&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD&MNT_CUSTOM1=utm_source') }
    end
  end
end