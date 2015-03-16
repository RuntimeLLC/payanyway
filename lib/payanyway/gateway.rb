require 'singleton'
require 'yaml'
require 'forwardable'

module Payanyway
  class Gateway
    include Singleton
    PARAMS = {
      'MNT_ID'             => :moneta_id,
      'MNT_TEST_MODE'      => :test_mode,
      'MNT_CURRENCY_CODE'  => :currency,
      'MNT_SUCCESS_URL'    => :success_url,
      'MNT_FAIL_URL'       => :fail_url,
      'MNT_RETURN_URL'     => :return_url,
      'MNT_INPROGRESS_URL' => :inprogress_url
    }.to_settings

    attr_reader :config, :config_for_moneta

    def initialize
      @env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @config = load_config
      @config_for_moneta = PARAMS.configure_by(@config)
    end

    def payment_url(params, use_signature = false)
      # Возвращает url на шлюз для входных параметров params
      #   * _params_                  - параметры платежа.
      #   * _use_signature_           - отправить код для идентификации отправителя и проверки целостности данных.
      #
      #   Обязателные:
      #     * _params[order_id]_      - номер заказа в магазине.
      #     * _params[amount]_        - сумма заказа.
      #     * _params[currency_code]_ - ISO код валюты (при остутствие береться из конфига).
      #
      #   Необязательные:
      #     * _params[test_mode]_     - Указание, что запрос происходит в тестовом режиме.
      #     * _params[description]_   - Описание оплаты.
      #     * _params[subscriber_id]_ - Внутренний идентификатор пользователя в системе магазина.
      #     * _params[custom1]_       - Поля произвольных параметров.
      #     * _params[custom2]_       - Поля произвольных параметров.
      #     * _params[custom3]_       - Поля произвольных параметров.

      Payanyway::Helpers::PaymentUrl.build(params, use_signature)
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