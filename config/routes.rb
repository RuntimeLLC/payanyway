Payanyway::Engine.routes.draw do
  get 'success'     => 'payanyway#success',        as: :payanyway_on_success
  match 'pay'       => 'payanyway#pay',            as: :payanyway_pay,           via: [:get, :post]
  get 'fail'        => 'payanyway#fail',           as: :payanyway_on_fail
  get 'return'      => 'payanyway#return',         as: :payanyway_on_return
  get 'in_progress' => 'payanyway#in_progress',    as: :payanyway_in_progress
  match 'check'     => 'payanyway#check',          as: :payanyway_on_check,      via: [:get, :post]
end
