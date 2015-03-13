module Payanyway
  module Response
    class Notify
      PARAMS = {
        'OutSum'         => :amount,
        'InvId'          => :invoice_id,
        'SignatureValue' => :signature,
        'Culture'        => :language
      }

      def self.perfom(params)
        new(params).perform
      end

      def initialize(params)
        @params = params
      end

      def perfom
        parsed_params = map_params(params, @@notification_params_map)
        validate_signature(parsed_params)

        success_implementation(parsed_params)
      end

      def validate_signature(parsed_params)

      end

      def map_params(params, map)
        Hash[ params.map { |key, value| [ (map[key] || map[key.to_sym ] || key), value] } ]
      end

      def success_implementation(parsed_params)
        # this is called by robokassa server, to actually validate payment
        # Secure.
      end
    end
  end
end