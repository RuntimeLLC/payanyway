describe PayanywayController do
  routes { Payanyway::Engine.routes }

  describe 'GET #pay' do

    it 'should render "FAIL" text' do
      get :pay
      expect(response.body).to eq('FAIL')
    end

  end

  describe 'POST #pay' do

    it 'should render "FAIL" text' do
      post :pay
      expect(response.body).to eq('FAIL')
    end

  end

  describe 'GET #success' do
    it 'should add message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Called success payment url for order '676'").and_call_original

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
    it 'should add message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Return from payanyway. Order '676'")

      get :return, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  describe 'GET #in_progress' do
    it 'should add message to logger' do
      expect(Rails.logger).to receive(:info).with("PAYANYWAY: Order '676' in progress")

      get :in_progress, { 'MNT_TRANSACTION_ID' => 676 }
    end
  end

  [:get, :post].each do |method|

    describe "#{method.upcase} #check" do
      context 'when empty params' do
        it 'should raise error' do
          expect{
            public_send(method, :check)
          }.not_to raise_error
        end
      end

      context 'when invalid signature' do
        it 'should raise error' do
          expect{ public_send(method, :check, { 'MNT_TRANSACTION_ID' => 676 }) }.to raise_error
        end
      end

      context 'when valid signature' do
        it 'should add message to logger' do
          expect(Rails.logger).not_to receive(:info).with(/PAYANYWAY: XML response for check/)
          expect_any_instance_of(Payanyway::Controller).
            to receive(:check_implementation).and_return(amount: 12, state: :paid)

          public_send method, :check, {
            'MNT_ID' =>  Payanyway::Gateway.config['moneta_id'].to_s,
            'MNT_TRANSACTION_ID' => 676,
            'MNT_SIGNATURE' => '79c1c4f41a0a70bb107c976ebba25811'
          }

          expect(Nokogiri::XML(response.body).at_css('MNT_RESPONSE')).to be_present
        end
      end

      context 'when logger flag is true' do
        it 'should add message to logger' do
          expect(Rails.logger).to receive(:info).with(/PAYANYWAY: XML response for check/)

          expect_any_instance_of(Payanyway::Controller).
            to receive(:check_implementation).and_return(amount: 12, state: :paid, logger: true)
          public_send method, :check, {
            'MNT_ID' =>  Payanyway::Gateway.config['moneta_id'].to_s,
            'MNT_TRANSACTION_ID' => 676,
            'MNT_SIGNATURE' => '79c1c4f41a0a70bb107c976ebba25811'
          }
        end
      end
    end

  end
end
