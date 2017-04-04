module Payanyway
  module Factories
    class WidgetUrlFactory
      def self.build(params, use_signature)
        [
          Payanyway::Gateway.config['widget_url'],
          Payanyway::Factories::QueryParamsFactory.build(params, use_signature)
        ].join('?')
      end
    end
  end
end
