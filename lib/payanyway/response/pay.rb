module Payanyway
  module Response
    class Pay
      PARAMS = {
        'MNT_ID'             => :moneta_id,
        'MNT_TRANSACTION_ID' => :order_id,
        'MNT_OPERATION_ID'   => :operation_id,
        'MNT_AMOUNT'         => :amount,
        'MNT_CURRENCY_CODE'  => :currency,
        'MNT_SUBSCRIBER_ID'  => :subscriber_id,
        'MNT_TEST_MODE'      => :test_mode,
        'MNT_SIGNATURE'      => :signature,
        'MNT_USER'           => :user,
        'MNT_CORRACCOUNT'    => :corraccount,
        'MNT_CUSTOM1'        => :custom1,
        'MNT_CUSTOM2'        => :custom2,
        'MNT_CUSTOM3'        => :custom3,
      }.invert.to_settings

      attr_reader :pretty_params

      def initialize(params)
        @params = params
        @pretty_params = PARAMS.configure_by(params)
      end

      def perform
        @valid_signature = (@pretty_params[:signature] == signature)
      end

      def success?
        @valid_signature
      end

      def result
        @valid_signature ? 'SUCCESS' : 'FAIL'
      end

      private

      def signature
        Payanyway::Helpers::SignatureGenerate.for_pay(@params)
      end
    end
  end
end