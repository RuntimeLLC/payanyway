module Payanyway
  module Request
    class Base
      @@_params = { 'MNT_TRANSACTION_ID' => :transaction_id }.invert.to_settings

      attr_reader :pretty_params

      def initialize(params)
        @params = params
        @pretty_params = @@_params.configure_by(params)
      end

      def error_message
        "ERROR! Invalid signature for order #{ @pretty_params[:transaction_id] }. Params: #{ @params.inspect }"
      end
    end
  end
end
