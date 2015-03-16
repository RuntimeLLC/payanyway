describe PayanywayController do
  routes { Payanyway::Engine.routes }

  describe 'GET #success' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:info).with("Called success payment url for order '676'")

      get :success, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #fail' do
    it 'should and message to logger' do
      expect(Rails.logger).to receive(:error).with("Fail paid order '676'")

      get :fail, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end
end