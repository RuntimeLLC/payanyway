require 'uri'

describe Payanyway::Factories::QueryParamsFactory do
  subject do
    built_params = described_class.build(params, false)

    Hash[ URI.decode_www_form(built_params) ]
  end

  context 'when reset urls' do
    let(:params) {
      {
        amount: '120.25',
        transaction_id: 'FF790ABCD',
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
        transaction_id: 'FF790ABCD',
        locale: 'ru',
        payment_system_limit_ids: '1015,1017'
      }
    }

    its(['moneta.locale']) { is_expected.to eq('ru') }
    its(['paymentSystem.limitIds']) { is_expected.to eq('1015,1017') }
  end

  context 'when set additional params (for automatic MONETA.Assistant process)' do
    let(:params) {
      {
        followup: true,
        payment_system_unit_id: '1017',# (1015 – МОНЕТА.РУ, 1020 – Яндекс.Деньги, 1017 – WebMoney и т.п.)
        javascript_enabled: true,
        payment_system_account_id: 2 # 2 – WMR, 3 – WMZ, 4 – WME.
      }
    }

    its(['followup']) { is_expected.to eq('true') }
    its(['paymentSystem.unitId']) { is_expected.to eq('1017') }
    its(['javascriptEnabled']) { is_expected.to eq('true') }
    its(['paymentSystem.accountId']) { is_expected.to eq('2') }
  end
end
