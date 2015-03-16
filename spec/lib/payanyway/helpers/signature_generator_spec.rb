require 'digest/md5'

describe Payanyway::Helpers::SignatureGenerate do
  describe '#for_pay' do
    subject { described_class.for_pay(params) }

    let(:params) {
      {
        'MNT_ID'             => 1,
        'MNT_TRANSACTION_ID' => 2,
        'MNT_OPERATION_ID'   => 3,
        'MNT_AMOUNT'         => 10.20,
        'MNT_CURRENCY_CODE'  => 'RUB',
        'MNT_TEST_MODE'      => 1
      }
    }

    it { should eq(Digest::MD5.hexdigest('12310.20RUB1secret_token').downcase) }
  end
end