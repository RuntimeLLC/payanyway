module Payanyway
  module Response
    class InvalidState < Exception; end
  end

  module Request
    class Check < Base
      SPECIAL_CODE  = 100 # когда в запросе не было суммы, а мы её передает в ответе
      RESPONSE_CODE = {
        paid:        200,
        in_progress: 302,
        unpaid:      402,
        canceled:    500
      }

      @@_params = {
          'MNT_COMMAND'          => :command,
          'MNT_ID'               => :moneta_id,
          'MNT_TRANSACTION_ID'   => :transaction_id,
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

      def initialize(params)
        super
        @valid_signature = (@pretty_params[:signature] == Payanyway::Helpers::SignatureGenerate.for_check(@params))
      end

      def success?
        @valid_signature
      end

      def response(attr)
        # Возвращает Nokogiri::XML документ
        #  * _attr[:amount]      - сумма заказа
        #  * _attr[:state]      - статус платежа(см. RESPONSE_CODE)
        #  * _attr[:description] - Произвольное описание заказа (необязятельно)
        #  * _attr[:attributes]  - Произвольный атрибуты заказа (необязятельно)

        validate_status!(attr[:state])

        xml = base_xml(attr[:amount], attr[:state], attr[:description])
        parent = xml.at_css('MNT_RESPONSE')

        parent.add_child(signature_node(xml))
        parent.add_child(attributes_node(attr[:attributes], xml)) if attr[:attributes].present?

        add_to_logger(xml) if attr[:logger]

        xml
      end

      private

      def validate_status!(state)
        if RESPONSE_CODE.keys.exclude?(state.to_sym)
          raise Payanyway::Response::InvalidState.new("PAYANYWAY: Invalid response state! State must be eq #{ RESPONSE_CODE.keys }")
        end
      end

      def base_xml(amount, state, description)
        xml = <<-EOXML
          <MNT_RESPONSE>
            <MNT_ID>#{ Payanyway::Gateway.config['moneta_id'] }</MNT_ID>
            <MNT_TRANSACTION_ID>#{ @pretty_params[:transaction_id] }</MNT_TRANSACTION_ID>
            <MNT_RESULT_CODE>#{ result_code_of(amount, state) }</MNT_RESULT_CODE>
            <MNT_DESCRIPTION>#{ description }</MNT_DESCRIPTION>
            <MNT_AMOUNT>#{ amount }</MNT_AMOUNT>
          </MNT_RESPONSE>
        EOXML

        Nokogiri::XML(xml, nil, 'UTF-8')
      end

      def signature_node(xml)
        create_new_node('MNT_SIGNATURE',
          Payanyway::Helpers::SignatureGenerate.for_check_response(Hash.from_xml(xml.to_s)['MNT_RESPONSE']),
          xml
        )
      end

      def result_code_of(amount, state)
        if @pretty_params[:amount].blank? && amount.present?
          SPECIAL_CODE
        else
          RESPONSE_CODE[state.to_sym]
        end
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

      def add_to_logger(xml)
        Rails.logger.info("PAYANYWAY: XML response for check: \r\n #{ xml.to_xml }")
      end
    end
  end
end
