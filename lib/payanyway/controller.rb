module Payanyway
  module Controller
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token
    end

    def pay
      service = Payanyway::Response::Pay.new(params)
      service.perform
      pay_implementation(service.pretty_params) if service.success?

      render text: service.result
    end

    def success
      result = Payanyway::Response::Success.perform(params, self)
      redirect_to result if result.is_a?(String)
    end

    def fail
      result = Payanyway::Response::Fail.perform(params, self)
      redirect_to result if result.is_a?(String)
    end

    private

    def pay_implementation(params)
      # Вызывается после успешного прохождения
      # запроса от оплате от moneta.ru
    end
  end
end

# MNT_SIGNATURE = MD5(
#     MNT_ID + MNT_TRANSACTION_ID + MNT_AMOUNT + MNT_CURRENCY_CODE +
#         MNT_SUBSCRIBER_ID + ТЕСТОВЫЙ РЕЖИМ + КОД ПРОВЕРКИ ЦЕЛОСТНОСТИ