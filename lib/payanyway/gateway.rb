require 'singleton'
require 'yaml'
require 'forwardable'

module Payanyway
  class Gateway
    include Singleton
    PARAMS = {
      'MNT_ID'             => :moneta_id,
      'MNT_TEST_MODE'      => :test_mode,
      'MNT_CURRENCY_CODE'  => :currency
    }.to_settings

    attr_reader :config, :config_for_moneta

    def initialize
      @env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @config = load_config
      @config_for_moneta = PARAMS.configure_by(@config)
    end

    def payment_url(params, use_signature = true)
      # Возвращает url на шлюз для входных параметров params
      #   * _params_                  - параметры платежа.
      #   * _use_signature_           - отправить код для идентификации отправителя и проверки целостности данных.
      #
      #   Обязателные:
      #     * _params[transaction_id]_  - номер заказа в магазине.
      #     * _params[amount]_          - сумма заказа.
      #
      #   Необязательные:
      #     * _params[test_mode]_     - Указание, что запрос происходит в тестовом режиме.
      #     * _params[description]_   - Описание оплаты.
      #     * _params[subscriber_id]_ - Внутренний идентификатор пользователя в системе магазина.
      #     * _params[custom1]_       - Поля произвольных параметров.
      #     * _params[custom2]_       - Поля произвольных параметров.
      #     * _params[custom3]_       - Поля произвольных параметров.
      #     * _params[locale]_        - (ru|en) Язык пользовательского интерфейса.

      #     * _params[payment_system_unit_id ]_   - Предварительный выбор платежной системы. (https://www.moneta.ru/viewPaymentMethods.htm)
      #     * _params[payment_system_limit_ids ]_ - Список (разделенный запятыми) идентификаторов платежных систем, которые необходимо показывать пользователю. (https://www.moneta.ru/viewPaymentMethods.htm)

      #  Эти параметры используются только тогда, когда в настройках счета выставлен флаг «Можно переопределять настройки в URL»
      #     * _params[success_url]_   - URL страницы магазина, куда должен попасть покупатель после успешно выполненных действий.
      #     * _params[inprogress_url]_- URL страницы магазина, куда должен попасть покупатель после успешного запроса на авторизацию средств, до подтверждения списания и зачисления средств.
      #     * _params[fail_url]_      - URL страницы магазина, куда должен попасть покупатель после отмененной или неуспешной оплаты.
      #     * _params[return_url]_    - URL страницы магазина, куда должен вернуться покупатель при добровольном отказе от оплаты.


      Payanyway::Factories::PaymentUrlFactory.build(params, use_signature)
    end

    def widget_url(params, use_signature = true)
      Payanyway::Factories::WidgetUrlFactory.build(params, use_signature)
    end

    class << self
      extend Forwardable
      def_delegators(:instance, *Payanyway::Gateway.instance_methods(false))
    end

    private

    def load_config
      YAML.load(File.read(File.join(Rails.root, 'config/payanyway.yml')))[@env]
    end
  end
end
