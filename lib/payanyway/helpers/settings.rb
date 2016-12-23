class Hash
  def to_settings
    Payanyway::Helpers::Settings.new(self)
  end
end

module Payanyway
  module Helpers
    class Settings
      delegate :[], to: '@settings'

      def initialize(settings)
        @settings = HashWithIndifferentAccess.new(settings.invert)
      end

      # Выбирает из настроек нужные
      # и подставляет в переданный hash
      #
      #   @settings = { 'MNT_ID' => :id, 'MNT_CURRENCY' => :currency }
      #   hash = { id: 1 }
      #   => { 'MNT_ID': 1 }
      def configure_by(hash)
        hash.each_with_object({}) do |(key, value), memo|
          memo[ @settings[key] ] = value if @settings.has_key?(key)
        end
      end
    end
  end
end
