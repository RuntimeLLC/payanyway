module Payanyway
  module Controller
    extend ActiveSupport::Concern

    included do
      skip_before_filter :verify_authenticity_token
    end

    def notify
      render text: Payanyway::Response::Notify.perform(params)
    end

    def success
      result = Payanyway::Response::Success.perform(params, self)
      redirect_to result if result.is_a?(String)
    end

    def fail
      result = Payanyway::Response::Fail.perform(params, self)
      redirect_to result if result.is_a?(String)
    end
  end
end