module Payanyway
  module Controller
    extend ActiveSupport::Concern

      included do
      skip_before_filter :verify_authenticity_token
    end

    def pay
      service = Payanyway::Response::Pay.new(params)
      service.perform
      service.success? ?
        pay_implementation(service.pretty_params) :
        error_log(service.pretty_params)

      render text: service.result
    end

    def success
      service = Payanyway::Response::Success.new(params)
      success_implementation(service.pretty_params)
    end

    def fail
      service = Payanyway::Response::Success.perform(params, self)
      fail_implementation(service.pretty_params)
    end

    private

    def error_log(params)
      Payanyway::Engine.logger.info("ERROR! Invalid signature for order #{ params[:order_id] }. Params: #{ params.inspect }")
    end

    def pay_implementation(params)
      # Вызывается после успешного прохождения
      # запроса об оплате от moneta.ru

      Payanyway::Engine.logger.info("Success paid order #{ params[:order_id] }")
    end

    def success_implementation(params)
      # Переправляется пользователь после успешной оплаты

      Payanyway::Engine.logger.info("Redirect to success payment url for order #{ params[:order_id] }")
    end

    def fail_implementation(params)
      # Переправляется пользователь после успешной оплаты

      Payanyway::Engine.logger.info("Fail paid order #{ params[:order_id] }")
    end
  end
end
