Payanyway::Engine.routes.draw do
  get 'success' => 'payanyway#success',        as: :payanyway_on_success
  get 'notify'  => 'payanyway#notify',         as: :payanyway_notification
  get 'fail'    => 'payanyway#fail',           as: :payanyway_on_fail
end