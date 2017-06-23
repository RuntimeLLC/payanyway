describe PayanywayController do
  routes { Payanyway::Engine.routes }

  describe 'GET #pay' do

    describe 'rendering' do
      before(:each){ allow(Rails).to receive(:version){ rails_version } }

      context 'when Rails version is "5.1"' do
        let(:rails_version){ '5.1' }

        it 'renders using :plain' do
          expect(controller).to receive(:render).with(:plain => anything).and_call_original
          get :pay
        end
      end

      context 'when Rails version is greater than "5.1"' do
        let(:rails_version){ %w(5.1.2 5.3.3 6.0).sample }

        it 'renders using :plain' do
          expect(controller).to receive(:render).with(:plain => anything).and_call_original
          get :pay
        end
      end

      context 'when Rails version is less than "5.1"' do
        let(:rails_version){ %w(4.0.3 4.2.0 5.0.3).sample }

        it 'renders using :text' do
          expect(controller).to receive(:render).with(:text => anything).and_call_original
          get :pay
        end
      end

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
      it 'should add message to logger' do
        expect(Rails.logger).not_to receive(:info).with(/PAYANYWAY: XML response for check/)
        expect_any_instance_of(Payanyway::Controller).to receive(:check_implementation).and_return(amount: 12, state: :paid)

        get :check, { 'MNT_ID' =>  Payanyway::Gateway.config['moneta_id'].to_s, 'MNT_TRANSACTION_ID' => 676, 'MNT_SIGNATURE' => '79c1c4f41a0a70bb107c976ebba25811' }

        expect(Nokogiri::XML(response.body).at_css('MNT_RESPONSE')).to be_present
      end
    end

    context 'when logger flag is true' do
      it 'should add message to logger' do
        expect(Rails.logger).to receive(:info).with(/PAYANYWAY: XML response for check/)

        expect_any_instance_of(Payanyway::Controller).to receive(:check_implementation).and_return(amount: 12, state: :paid, logger: true)
        get :check, { 'MNT_ID' =>  Payanyway::Gateway.config['moneta_id'].to_s, 'MNT_TRANSACTION_ID' => 676, 'MNT_SIGNATURE' => '79c1c4f41a0a70bb107c976ebba25811' }
      end
    end
  end
end
