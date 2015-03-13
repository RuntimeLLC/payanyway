describe Payanyway::Response::Pay do
  let(:service) { described_class.new(params) }
  let(:params) do
    {
      'MNT_ID'             => 1,
      'MNT_TRANSACTION_ID' => 2,
      'MNT_OPERATION_ID'   => 3,
      'MNT_AMOUNT'         => 10.20,
      'MNT_CURRENCY_CODE'  => 'RUB',
      'MNT_SUBSCRIBER_ID'  => 4,
      'MNT_TEST_MODE'      => 0,
      'MNT_SIGNATURE'      => :signature
    }
  end

  describe '#pretty_params' do
    subject { service.pretty_params }

    its([:moneta_id]) { is_expected.to eq(1) }
    its([:amount]) { is_expected.to eq(10.20) }
  end

  describe '#perform' do
    subject { service.success? }

    context 'when success' do
      before { service.perform }

      it { is_expected.to be_truthy }
    end
  end
end