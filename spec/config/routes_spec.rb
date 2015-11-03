describe Payanyway::Engine, type: :routing do
  routes { Payanyway::Engine.routes }

  context 'payanyway' do
    specify { expect(get('/success')).to route_to(
       controller: 'payanyway',
       action: 'success'
    )}

    specify { expect(get('/pay')).to route_to(
      controller: 'payanyway',
      action: 'pay'
    )}

    specify { expect(get('/fail')).to route_to(
      controller: 'payanyway',
      action: 'fail'
    )}

    specify { expect(get('/return')).to route_to(
      controller: 'payanyway',
      action: 'return'
    )}

    specify { expect(get('/in_progress')).to route_to(
      controller: 'payanyway',
      action: 'in_progress'
    )}

    specify { expect(get('/check')).to route_to(
      controller: 'payanyway',
      action: 'check'
    )}
  end
end
