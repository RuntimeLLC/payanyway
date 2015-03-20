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
end
