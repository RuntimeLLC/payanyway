require 'digest/md5'

module Payanyway
  module Helpers
    class SignatureGenerate
      class << self
        PAY = %w(
          MNT_ID
          MNT_TRANSACTION_ID
          MNT_OPERATION_ID
          MNT_AMOUNT
          MNT_CURRENCY_CODE
          MNT_SUBSCRIBER_ID
          MNT_TEST_MODE
        )
        def for_pay(params)
          md5(PAY.map { |key| get_value(params, key) }.join.concat(Payanyway::Gateway.config['token']))
        end

        private

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