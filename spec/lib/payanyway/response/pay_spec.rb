describe Payanyway::Response::Pay do
  let(:service) { described_class.new(params) }
  let(:params) do
    {
      'MNT_ID'             => 1,
      'MNT_TRANSACTION_ID' => 2,
      'MNT_OPERATION_ID'   => 3,
      'MNT_AMOUNT'         => 10.20,
      'MNT_CURRENCY_CODE'  => 'RUB',
      'MNT_TEST_MODE'      => 1,
      'MNT_SIGNATURE'      => '2b7f8d7d00e8e980b3df95dc70d47461'# from spec/lib/payanyway/helpers/signature_generator_spec.rb
    }
  end

  describe '#success?' do
    subject { service.success? }

    it { is_expected.to be_truthy }
  end
end
