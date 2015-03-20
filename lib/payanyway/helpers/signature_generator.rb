require 'digest/md5'

module Payanyway
  module Helpers
    class SignatureGenerate
      class << self
        # TODO need refactoring
        PAY_KEYS = %w(
          MNT_TRANSACTION_ID
          MNT_OPERATION_ID
          MNT_AMOUNT
          MNT_CURRENCY_CODE
          MNT_SUBSCRIBER_ID
          MNT_TEST_MODE
        )

        URL_KEYS = PAY_KEYS - [ 'MNT_OPERATION_ID' ]
        CHECK_KEYS = [ 'MNT_COMMAND' ] + PAY_KEYS

        CHECK_RESPONSE_KEYS = %w(
          MNT_RESULT_CODE
          MNT_ID
          MNT_TRANSACTION_ID
        )

        def for_pay(params)
          generate_by(params, PAY_KEYS)
        end

        def for_url(params)
          generate_by(params, URL_KEYS)
        end

        def for_check(params)
          generate_by(params, CHECK_KEYS)
        end

        def for_check_response(params)
          generate_by(params, CHECK_RESPONSE_KEYS)
        end

        private

        def generate_by(params, keys)
          values = keys.map { |key| get_value(params, key) }.join

          md5(Payanyway::Gateway.config['moneta_id'].to_s + values + Payanyway::Gateway.config['token'])
        end

        def get_value(params, key)
          (key == 'MNT_AMOUNT') ? '%.2f' % params[key] : params[key]
        end

        def md5(str)
          Digest::MD5.hexdigest(str).downcase
        end
      end
    end
  end
end