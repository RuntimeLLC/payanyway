module Payanyway
  module Factories
    class IframeUrlFactory < PaymentUrlFactory
      class << self
        def build(params, use_signature)
          params_for_moneta = prepare_params(params, use_signature)
          query_params = params_for_moneta.to_a.map { |option| option.map{ |opt| CGI::escape(opt.to_s) }.join('=') }.join('&')

          "#{ Payanyway::Gateway.config['iframe_url'] }?#{ query_params }"
        end
      end
    end
  end
end
