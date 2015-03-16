module Payanyway
  module Helpers
    class PaymentUrl
      PARAMS = {
          'MNT_TRANSACTION_ID' => :order_id,
          'MNT_DESCRIPTION'    => :description,
          'MNT_SUBSCRIBER_ID'  => :subscriber_id,
          'MNT_SIGNATURE'      => :signature,
          'MNT_AMOUNT'         => :amount,
          'MNT_CUSTOM1'        => :custom1,
          'MNT_CUSTOM2'        => :custom2,
          'MNT_CUSTOM3'        => :custom3,
      }.to_settings

      class << self
        def build(params, use_signature)
          params = prepare_params(params, use_signature)
          query_params = params.to_a.map { |option| option.map{ |opt| CGI::escape(opt.to_s) }.join('=') }.join('&')

          "#{ Payanyway::Gateway.config['payment_url'] }?#{ query_params }"
        end

        private

        def prepare_params(params, use_signature)
          params = PARAMS.configure_by(params)

          Payanyway::Gateway.config_for_moneta.merge(params)
          #add_signature(params) if use_signature
        end

        def add_signature(params)
          raise '#TODO'
        end
      end
    end
  end
end