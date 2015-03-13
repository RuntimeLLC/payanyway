module Payanyway
  module Response
    class Notify

      @@notification_params_map = {
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
        validate_signature
        parsed_params = map_params(params, @@notification_params_map)

        success_implementation(
          parsed_params[:invoice_id],
          parsed_params[:amount],
          parsed_params[:language]
        )
      end

      def map_params(params, map)
        Hash[ params.map { |key, value| [ (map[key] || map[key.to_sym ] || key), value] } ]
      end

      def success_implementation(invoice_id, amount, language)
        # this is called by robokassa server, to actually validate payment
        # Secure.
      end
    end
  end
end