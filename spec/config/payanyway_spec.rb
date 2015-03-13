describe Payanyway::Gateway do
  subject { described_class.config }

  its(['moneta_id']) { is_expected.to eq(141290) }
  its(['currency']) { is_expected.to eq('RUB') }
end