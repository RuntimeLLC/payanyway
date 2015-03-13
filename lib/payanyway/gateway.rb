require 'singleton'
require 'yaml'
require 'forwardable'

module Payanyway
  class Gateway
    include Singleton
    PARAMS = HashWithIndifferentAccess.new({
      'MNT_ID'             => :moneta_id,
      'MNT_TEST_MODE'      => :test_mode,
      'MNT_CURRENCY_CODE'  => :currency,
      'MNT_SUCCESS_URL'    => :success_url,
      'MNT_FAIL_URL'       => :fail_url,
      'MNT_RETURN_URL'     => :return_url,
      'MNT_INPROGRESS_URL' => :inprogress_url
    }.invert)

    attr_reader :config, :env

    def initialize
      @env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @config = load_config
    end

    def payment_url(params)
      PaymentUrl.new(config_for_moneta).build(params)
    end

    def config_for_moneta
      @config.each_with_object({}) do |(key, value), hash|
        hash[value] = PARAMS[key]
      end.invert
    end

    class << self
      extend Forwardable
      def_delegators(:instance, *Payanyway::Gateway.instance_methods(false))
    end

    private

    def load_config
      YAML.load(File.read(File.join(Payanyway::Engine.root, 'config/payanyway.yml')))[@env]
    end
  end

  class PaymentUrl
    BASE_URL = 'https://www.moneta.ru/assistant.htm'
    PARAMS = {
      'MNT_TRANSACTION_ID' => :order_id,
      'MNT_AMOUNT'         => :amount,
      'MNT_CUSTOM1'        => :custom1,
      'MNT_CUSTOM2'        => :custom2,
      'MNT_CUSTOM3'        => :custom3,
    }.invert

    def initialize(config)
      @config = config
    end

    def build(params)
      new_params = params.each_with_object({}) do |(key, value), hash|
        hash[value] = PARAMS[key]
      end.invert

      new_params = @config.merge(new_params)
      "#{ BASE_URL }?#{ new_params.to_a.map { |option| option.join('=') }.join('&') }"
    end
  end
end