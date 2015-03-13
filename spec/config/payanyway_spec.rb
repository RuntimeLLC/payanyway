describe Payanyway::Gateway do
  subject { described_class.config }

  its(['moneta_id']) { is_expected.to eq(141290) }
  its(['test_mode']) { is_expected.to eq(1) }
end