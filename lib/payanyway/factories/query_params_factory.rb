module Payanyway
  module Factories
    class QueryParamsFactory
      PARAMS = {
        'MNT_ID'                  => :moneta_id,
        'MNT_TEST_MODE'           => :test_mode,
        'MNT_CURRENCY_CODE'       => :currency,

        'MNT_TRANSACTION_ID'      => :transaction_id,
        'MNT_AMOUNT'              => :amount,
        'MNT_DESCRIPTION'         => :description,
        'MNT_SUBSCRIBER_ID'       => :subscriber_id,

        'MNT_SUCCESS_URL'         => :success_url,
        'MNT_INPROGRESS_URL'      => :in_progress_url,
        'MNT_FAIL_URL'            => :fail_url,
        'MNT_RETURN_URL'          => :return_url,

        'MNT_CUSTOM1'             => :custom1,
        'MNT_CUSTOM2'             => :custom2,
        'MNT_CUSTOM3'             => :custom3,

        'moneta.locale'           => :locale,
        'paymentSystem.limitIds'  => :payment_system_limit_ids,
        'operationId'             => :operation_id,

        # Дополнительные параметры запроса на оплату
        'followup'                => :followup,
        'paymentSystem.unitId'    => :payment_system_unit_id,
        'javascriptEnabled'       => :javascript_enabled,
        'paymentSystem.accountId' => :payment_system_account_id
        # 'MNT_SIGNATURE'        => добавляется при use_signature == true
      }.to_settings

      class << self
        def build(params, use_signature)
          params_for_moneta = prepare_params(params, use_signature)
          params_for_moneta.to_a.map { |option| option.map{ |opt| CGI::escape(opt.to_s) }.join('=') }.join('&')
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
