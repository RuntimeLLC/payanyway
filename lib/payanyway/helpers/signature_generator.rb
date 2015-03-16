require 'digest/md5'

module Payanyway
  module Helpers
    class SignatureGenerate
      class << self
        PAY_KEYS = %w(
          MNT_ID
          MNT_TRANSACTION_ID
          MNT_OPERATION_ID
          MNT_AMOUNT
          MNT_CURRENCY_CODE
          MNT_SUBSCRIBER_ID
          MNT_TEST_MODE
        )

        URL_KEYS = PAY_KEYS - [ 'MNT_OPERATION_ID' ]

        def for_pay(params)
          generate_by(params, PAY_KEYS)
        end


        def for_url(params)
          generate_by(params, URL_KEYS)
        end

        private

        def generate_by(params, keys)
          md5(keys.map { |key| get_value(params, key) }.join.concat(Payanyway::Gateway.config['token']))
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