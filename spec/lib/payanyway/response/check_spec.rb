describe Payanyway::Response::Check do
  RSpec::Matchers.define :be_eq_node do |expected|
    def value_of(node)
      elements = node.children.select { |e| e.instance_of? Nokogiri::XML::Element }
      elements.map { |el| [ el.name, el.children.many? ? value_of(el) : el.children.text ] }
    end

    match do |actual|
      value_of(actual) == value_of(expected)
    end
  end

  let(:service) { described_class.new(params) }
  let(:request_amount) { 10.20 }
  let(:params) do
    {
      'MNT_TRANSACTION_ID' => 2,
      'MNT_OPERATION_ID'   => 3,
      'MNT_AMOUNT'         => request_amount,
      'MNT_CURRENCY_CODE'  => 'RUB',
      'MNT_TEST_MODE'      => 1
    }
  end

  describe '#result' do
    let(:xml) { service.result(amount, status, description, attributes) }
    let(:amount) { request_amount }
    let(:status) { :unpaid }
    let(:description) { 'Заказ создан, но не оплачен' }
    let(:attributes) { {} }

    context 'when code 402' do
      it 'should valid xml' do
        expected = <<-XML
          <MNT_RESPONSE>
            <MNT_ID>141290</MNT_ID>
            <MNT_TRANSACTION_ID>2</MNT_TRANSACTION_ID>
            <MNT_RESULT_CODE>402</MNT_RESULT_CODE>
            <MNT_DESCRIPTION>Заказ создан, но не оплачен</MNT_DESCRIPTION>
            <MNT_AMOUNT>10.2</MNT_AMOUNT>
            <MNT_SIGNATURE>061c2b859c27c75db9e5bbef3aef90a0</MNT_SIGNATURE>
          </MNT_RESPONSE>
        XML
        expected_xml = Nokogiri::XML(expected, nil, 'UTF-8')

        expect(xml.at_css('MNT_RESPONSE')).to be_eq_node(expected_xml.at_css('MNT_RESPONSE'))
      end
    end

    context 'when have attributes' do
      let(:attributes) { { type: 'chocolate', brand: 'Mars' } }

      it 'should generate attributes xml' do
        expected = <<-XML
          <MNT_RESPONSE>
            <MNT_ATTRIBUTES>
              <ATTRIBUTE>
                <KEY>type</KEY>
                <VALUE>chocolate</VALUE>
              </ATTRIBUTE>
              <ATTRIBUTE>
                <KEY>brand</KEY>
                <VALUE>Mars</VALUE>
              </ATTRIBUTE>
            </MNT_ATTRIBUTES>
          </MNT_RESPONSE>
        XML

        expected_xml = Nokogiri::XML(expected, nil, 'UTF-8')
        expect(xml.at_css('MNT_ATTRIBUTES')).to be_eq_node(expected_xml.at_css('MNT_ATTRIBUTES'))
      end
    end
  end
end