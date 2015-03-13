require 'singleton'
require 'yaml'
require 'forwardable'

module Payanyway
  class Gateway
    include Singleton

    attr_reader :config, :env

    class << self
      extend Forwardable
      def_delegators(:instance, *Payanyway::Gateway.instance_methods(false))
    end

    def initialize
      @env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
      @config = load_config
    end

    def payment_url
      # need implementation
    end

    private

    def load_config
      YAML.load(File.read(File.join(Payanyway::Engine.root, 'config/payanyway.yml')))[@env]
    end
  end
end