describe Payanyway::Engine, type: :routing do
  routes { Payanyway::Engine.routes }

  context 'payanyway' do
    specify { get('/success').should route_to(
       controller: 'payanyway',
       action: 'success'
    )}

    specify { get('/notify').should route_to(
      controller: 'payanyway',
      action: 'notify'
    )}

    specify { get('/fail').should route_to(
      controller: 'payanyway',
      action: 'fail'
    )}
  end
end
