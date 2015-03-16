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
      Payanyway::Helpers::PaymentUrl.build(params, use_signature)
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
end