module Payanyway
  module Response
    class Base
      @@_params = { 'MNT_TRANSACTION_ID' => :order_id }.invert.to_settings

      attr_reader :pretty_params

      def initialize(params)
        @params = params
        @pretty_params = @@_params.configure_by(params)
      end
    end
  end
end