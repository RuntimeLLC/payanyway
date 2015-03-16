module Payanyway
  module Helpers
    class PaymentUrl
      PARAMS = {
          'MNT_TRANSACTION_ID' => :order_id,
          'MNT_DESCRIPTION'    => :description,
          'MNT_SUBSCRIBER_ID'  => :subscriber_id,
          'MNT_AMOUNT'         => :amount,
          'MNT_CUSTOM1'        => :custom1,
          'MNT_CUSTOM2'        => :custom2,
          'MNT_CUSTOM3'        => :custom3
          # 'MNT_SIGNATURE'    => добавляется при use_signature == true
      }.to_settings

      class << self
        def build(params, use_signature)
          params_for_moneta = prepare_params(params, use_signature)
          query_params = params_for_moneta.to_a.map { |option| option.map{ |opt| CGI::escape(opt.to_s) }.join('=') }.join('&')

          "#{ Payanyway::Gateway.config['payment_url'] }?#{ query_params }"
        end

        private

        def prepare_params(params, use_signature)
          params_for_moneta = PARAMS.configure_by(params)
          params_for_moneta = Payanyway::Gateway.config_for_moneta.merge(params_for_moneta)

          use_signature ? add_signature(params_for_moneta) : params_for_moneta
        end

        def add_signature(params_for_moneta)
          params_for_moneta.merge({
            'MNT_SIGNATURE' => Payanyway::Helpers::SignatureGenerate.for_url(params_for_moneta)
          })
        end
      end
    end
  end
end