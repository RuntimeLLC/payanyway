module Payanyway
  module Controller
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token
    end

    def pay
      service = Payanyway::Response::Pay.new(params)
      service.success? ?
        pay_implementation(service.pretty_params) :
        Rails.logger.error(service.error_message)

      render text: service.result
    end

    def success
      service = Payanyway::Response::Base.new(params)

      success_implementation(service.pretty_params)
    end

    def fail
      service = Payanyway::Response::Base.new(params)

      fail_implementation(service.pretty_params[:order_id])
    end

    def return
      service = Payanyway::Response::Base.new(params)

      return_implementation(service.pretty_params[:order_id])
    end

    def in_progress
      service = Payanyway::Response::Base.new(params)

      in_progress_implementation(service.pretty_params[:order_id])
    end

    def check
      service = Payanyway::Response::Check.new(params)
      raise service.error_message unless service.success?

      render xml: service.result(check_implementation(service.pretty_params)).to_xml
    end

    private

    def pay_implementation(params)
      # Вызывается после успешного прохождения
      # запроса об оплате от payanyway.ru

      Rails.logger.info("PAYANYWAY: Success paid order #{ params[:order_id] }")
    end

    def success_implementation(params)
      # Вызывается после успешной оплаты

      Rails.logger.info("PAYANYWAY: Called success payment url for order '#{ params[:order_id] }'")
      render nothing: true
    end

    def fail_implementation(order_id)
      # Вызывается после ошибки при оплате

      Rails.logger.error("PAYANYWAY: Fail paid order '#{ order_id }'")
      render nothing: true
    end

    def return_implementation(order_id)
      # Вызывается при добровольном отказе пользователем от оплаты

      Rails.logger.info("PAYANYWAY: Return from payanyway. Order '#{ order_id }'")
      render nothing: true
    end

    def in_progress_implementation(order_id)
      # Вызывается после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств

      Rails.logger.info("PAYANYWAY: Order '#{ order_id }' in progress")
      render nothing: true
    end

    def check_implementation(params)
      # Ответ на запрос о проверке заказа
      # { amount: AMOUNT, state: STATE, description: description, attributes: ATTRIBUTES }
    end
  end
end
