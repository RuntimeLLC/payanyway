require 'uri'

describe Payanyway::Factories::PaymentUrlFactory do
  subject do
    parse_url = URI(described_class.build(params, false))

    Hash[ URI.decode_www_form(parse_url.query) ]
  end

  context 'when reset urls' do
    let(:params) {
      {
        amount: '120.25',
        order_id: 'FF790ABCD',
        success_url: 'success_url',
        in_progress_url: 'in_progress_url',
        fail_url: 'fail_url',
        return_url: 'return_url'
      }
    }

    its(['MNT_SUCCESS_URL']) { is_expected.to eq('success_url') }
    its(['MNT_INPROGRESS_URL']) { is_expected.to eq('in_progress_url') }
    its(['MNT_FAIL_URL']) { is_expected.to eq('fail_url') }
    its(['MNT_RETURN_URL']) { is_expected.to eq('return_url') }
  end

  context 'when set payment params' do
    let(:params) {
      {
        amount: '120.25',
        order_id: 'FF790ABCD',
        locale: 'ru',
        payment_system_unit_id: '1015',
        payment_system_limit_ids: '1015,1017'
      }
    }

    its(['moneta.locale']) { is_expected.to eq('ru') }
    its(['paymentSystem.unitId']) { is_expected.to eq('1015') }
    its(['paymentSystem.limitIds']) { is_expected.to eq('1015,1017') }
  end
end