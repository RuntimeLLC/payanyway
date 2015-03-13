describe Payanyway::Gateway do
  describe '#payment_url' do
    subject { described_class.payment_url(params) }

    context 'when min params' do
      let(:params) { { amount: '120.25', order_id: 'FF790ABCD' } }

      it { is_expected.to eq('https://www.moneta.ru/assistant.htm?MNT_ID=141290&MNT_CURRENCY_CODE=RUB&MNT_AMOUNT=120.25&MNT_TRANSACTION_ID=FF790ABCD') }
    end
  end
end