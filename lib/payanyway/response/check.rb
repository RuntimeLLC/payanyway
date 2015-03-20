module Payanyway
  module Response
    class Check < Base
      @@_params = {
          'MNT_COMMAND'          => :command,
          'MNT_ID'               => :moneta_id,
          'MNT_TRANSACTION_ID'   => :order_id,
          'MNT_OPERATION_ID'     => :operation_id,
          'MNT_AMOUNT'           => :amount,
          'MNT_CURRENCY_CODE'    => :currency,
          'MNT_SUBSCRIBER_ID'    => :subscriber_id,
          'MNT_TEST_MODE'        => :test_mode,
          'MNT_SIGNATURE'        => :signature,
          'MNT_USER'             => :user,
          'MNT_CORRACCOUNT'      => :corraccount,
          'MNT_CUSTOM1'          => :custom1,
          'MNT_CUSTOM2'          => :custom2,
          'MNT_CUSTOM3'          => :custom3,
          'paymentSystem.unitId' => :payment_system_unit_id
      }.invert.to_settings

      def perform
        # TODO move to initializer
        @valid_signature =
            (@pretty_params[:signature] == Payanyway::Helpers::SignatureGenerate.for_check(@params))
      end

      def success?
        @valid_signature
      end

      def result(amount, status, description, attributes = {})
        xml = base_xml(amount, status, description)
        parent = xml.at_css('MNT_RESPONSE')

        parent.add_child(signature_node(xml))
        parent.add_child(attributes_node(attributes, xml)) if attributes.present?

        xml
      end

      private

      def base_xml(amount, status, description)
        xml = <<-EOXML
          <MNT_RESPONSE>
            <MNT_ID>#{ Payanyway::Gateway.config['moneta_id'] }</MNT_ID>
            <MNT_TRANSACTION_ID>#{ @pretty_params[:order_id] }</MNT_TRANSACTION_ID>
            <MNT_RESULT_CODE>#{ result_code_of(amount, status) }</MNT_RESULT_CODE>
            <MNT_DESCRIPTION>#{ description }</MNT_DESCRIPTION>
            <MNT_AMOUNT>#{ amount }</MNT_AMOUNT>
          </MNT_RESPONSE>
        EOXML

        Nokogiri::XML(xml, nil, 'UTF-8')
      end

      def signature_node(xml)
        create_new_node(
          'MNT_SIGNATURE',
          Payanyway::Helpers::SignatureGenerate.for_check_response(Hash.from_xml(xml.to_s)['MNT_RESPONSE']),
          xml
        )
      end

      def result_code_of(amount, status)
        402
      end

      def attributes_node(attributes, xml)
        Nokogiri::XML::Node.new('MNT_ATTRIBUTES', xml).tap do |node|
          attributes.each do |key, value|
            attr_node = Nokogiri::XML::Node.new('ATTRIBUTE', xml)
            attr_node.add_child(create_new_node('KEY', key.to_s, xml))
            attr_node.add_child(create_new_node('VALUE', value.to_s, xml))

            node.add_child(attr_node)
          end
        end
      end

      def create_new_node(name, content, xml)
        Nokogiri::XML::Node.new(name, xml).tap { |node| node.content = content }
      end
    end
  end
end