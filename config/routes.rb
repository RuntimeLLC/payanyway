PayAnyWay::Engine.routes.draw do
  get 'notify' => 'payanyway#notify',         as: :payanyway_notification
  get 'success' => 'payanyway#success',       as: :payanyway_on_success
  get 'fail' => 'payanyway#fail',             as: :payanyway_on_fail
end