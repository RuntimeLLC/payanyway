describe PayanywayController do
  routes { Payanyway::Engine.routes }

  describe 'GET #success' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Called success payment url for order '676'")

      get :success, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #fail' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:error).with("PAYANYWAY: Fail paid order '676'")

      get :fail, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #return' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Return from payanyway. Order '676'")

      get :return, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #in_progress' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Order '676' in progress")

      get :in_progress, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #check' do
    context 'when empty params' do
      it 'should raise error' do
        expect{ get :check }.not_to raise_error
      end
    end

    context 'when invalid signature' do
      it 'should raise error' do
        expect{ get(:check, { 'MNT_TRANSACTION_ID' => 676 }) }.to raise_error
      end
    end

    context 'when valid signature' do
      it 'should and message to logger' do
        expect_any_instance_of(Payanyway::Controller).to receive(:check_implementation).and_return({amount: 12, state: :paid})
        get :check, { 'MNT_TRANSACTION_ID' => 676, 'MNT_SIGNATURE' => '79c1c4f41a0a70bb107c976ebba25811' }

        expect(Nokogiri::XML(response.body).at_css('MNT_RESPONSE')).to be_present
      end
    end
  end
end
