describe Payanyway::Request::Base do
  let(:service) { described_class.new(params) }
  let(:params) { { 'MNT_ID' => 1, 'MNT_AMOUNT' => 10.20 } }

  describe '#pretty_params' do
    subject { service.pretty_params }

    its([:moneta_id]) { is_expected.to eq(1) }
    its([:amount]) { is_expected.to eq(10.20) }
  end
end
