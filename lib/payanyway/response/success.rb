module Payanyway
  module Response
    class Success
      PARAMS = { 'MNT_TRANSACTION_ID' => :order_id }.invert.to_settings

      attr_reader :pretty_params

      def initialize(params)
        @params = params
        @pretty_params = PARAMS.configure_by(params)
      end
    end
  end
end