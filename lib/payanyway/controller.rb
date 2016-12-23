module Payanyway
  module Controller
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token
    end

    def pay
      request = Payanyway::Request::Pay.new(params)
      request.success? ?
        pay_implementation(request.pretty_params) :
        Rails.logger.error(request.error_message)

      render plain: request.response
    end

    def success
      request = Payanyway::Request::Base.new(params)

      success_implementation(request.pretty_params)
    end

    def fail
      request = Payanyway::Request::Base.new(params)

      fail_implementation(request.pretty_params[:transaction_id])
    end

    def return
      request = Payanyway::Request::Base.new(params)

      return_implementation(request.pretty_params[:transaction_id])
    end

    def in_progress
      request = Payanyway::Request::Base.new(params)

      in_progress_implementation(request.pretty_params[:transaction_id])
    end

    def check
      request = Payanyway::Request::Check.new(params)
      if request.pretty_params.present?
        raise request.error_message unless request.success?

        render xml: request.response(check_implementation(request.pretty_params)).to_xml
      else
        # Не выдавать ошибку, если параметры пустые
        # Необходимо для проверки со стороны moneta.ru
        render nothing: true
      end
    end

    private

    def pay_implementation(params)
      # Вызывается после успешного прохождения
      # запроса об оплате от payanyway.ru

      Rails.logger.info("PAYANYWAY: Success paid order #{ params[:transaction_id] }")
    end

    def success_implementation(params)
      # Вызывается после успешной оплаты

      Rails.logger.info("PAYANYWAY: Called success payment url for order '#{ params[:transaction_id] }'")
      render nothing: true
    end

    def fail_implementation(transaction_id)
      # Вызывается после ошибки при оплате

      Rails.logger.error("PAYANYWAY: Fail paid order '#{ transaction_id }'")
      render nothing: true
    end

    def return_implementation(transaction_id)
      # Вызывается при добровольном отказе пользователем от оплаты

      Rails.logger.info("PAYANYWAY: Return from payanyway. Order '#{ transaction_id }'")
      render nothing: true
    end

    def in_progress_implementation(transaction_id)
      # Вызывается после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств

      Rails.logger.info("PAYANYWAY: Order '#{ transaction_id }' in progress")
      render nothing: true
    end

    def check_implementation(params)
      # Ответ на запрос о проверке заказа
      # { amount: AMOUNT, state: STATE, description: description, attributes: ATTRIBUTES, logger: logger }

      { amount: params[:amount], state: :unpaid, description: 'Test description' }
    end
  end
end
