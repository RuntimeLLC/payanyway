require 'digest/md5'

module Payanyway
  module Helpers
    class SignatureGenerate
      BASE_KEYS = %w(
        MNT_ID
        MNT_TRANSACTION_ID
        MNT_OPERATION_ID
        MNT_AMOUNT
        MNT_CURRENCY_CODE
        MNT_SUBSCRIBER_ID
        MNT_TEST_MODE
      )

      KEYS = {
        pay: BASE_KEYS,
        url: BASE_KEYS - [ 'MNT_OPERATION_ID' ],
        check: [ 'MNT_COMMAND' ] + BASE_KEYS,
        check_response:  %w(MNT_RESULT_CODE MNT_ID MNT_TRANSACTION_ID)
      }

      KEYS.each do |key_name, keys|
        define_singleton_method("for_#{ key_name }") do |params|
          generate_by(params, keys)
        end
      end

      class << self
        private

        def generate_by(params, keys)
          values = keys.map { |key| get_value(params, key) }.join

          md5(values + Payanyway::Gateway.config['token'])
        end

        def get_value(params, key)
          if key == 'MNT_AMOUNT' && params[key].present?
            '%.2f' % params[key]
          else
            params[key]
          end
        end

        def md5(str)
          Digest::MD5.hexdigest(str).downcase
        end
      end
    end
  end
end