module Payanyway
  module Factories
    class PaymentUrlFactory
      def self.build(params, use_signature)
        [
          Payanyway::Gateway.config['payment_url'],
          Payanyway::Factories::QueryParamsFactory.build(params, use_signature)
        ].join('?')
      end
    end
  end
end
