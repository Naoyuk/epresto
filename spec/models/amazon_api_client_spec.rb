# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AmazonAPIClient, type: :model do
  describe '#get_purchase_orders' do
    context 'APIを不正な引数で叩いた時' do
      xit 'エラーを返す' do
        amazon_api = AmazonAPIClient.new

        # mock_response_access_token = {
        #   "access_token":"mock_acckess_token",
        #   "refresh_token":"mock_refresh_token",
        #   "token_type":"bearer","expires_in":3600
        # }
        # allow(amazon_api).to receive(:generate_access_token).and_return(mock_response_access_token)

        # params = {
        #   path: '/vendor/orders/v1/purchaseOrders',
        #   method: 'GET',
        #   created_after: '2023-01-01 10:00:00',
        #   created_before: '2023-01-07 10:00:00'
        # }
        # allow(amazon_api).to receive(:generate_url_and_sign(params)).and_return('invalid_url_and_sign')

        created_after = '2023-01-01 10:00:00'
        created_before = '2023-01-07 10:00:00'
        mock_response = "error response"
        allow(amazon_api).to receive(:get_purchase_orders).and_return(mock_response)
        expect(amazon_api.get_purchase_orders(created_after, created_before)).to eq 'error response'
      end
    end

    context 'APIを正しい引数で叩いた時' do
      xit 'PurchaseOrdersを返す' do
        amazon_api = AmazonAPIClient.new
        created_after = '2023-01-01 10:00:00'
        created_before = '2023-01-07 10:00:00'
        mock_response = 'success response'
        allow(amazon_api).to receive(:get_purchase_orders).and_return(mock_response)
        expect(amazon_api.get_purchase_orders(created_after, created_before)).to eq 'success response'
      end
    end
  end

  describe '#submit_acknowledgements' do
    context 'リクエストが正しくない場合' do
      xit 'エラーレスポンスが返る' do
        amazon_api = AmazonAPIClient.new
        mock_error_response = "{\n  \"errors\": [\n    {\n     \"message\": \"Invalid request body: [object has missing required properties ([\\\"items\\\"])]\",\n     \"code\": \"InvalidInput\"\n    }\n  ]\n}"
        allow(amazon_api).to receive(:submit_acknowledgements).and_return(mock_error_response)
        invalid_req_body = {"acknowledgements"=>[{"purchaseOrderNumber"=>"TestOrder01", "sellingParty"=>{"partyId"=>"test"}, "acknowledgementDate"=>"2023-01-23T15:01:52Z", "item"=>[]}]}
        response = amazon_api.submit_acknowledgements(invalid_req_body)
        expect(response).to eq mock_error_response
      end
    end

    context 'リクエストが正しい場合' do
      xit 'Transaction IDを含むレスポンスが返る' do
        amazon_api = AmazonAPIClient.new
        mock_success_response = "{\"payload\":{\"transactionId\":\"mock-TransactionId-20190827182357-8725bde9-c61c-49f9-86ac-46efd82d4da5\"}}"
        valid_req_body = {"acknowledgements"=>[{"purchaseOrderNumber"=>"TestOrder01", "sellingParty"=>{"partyId"=>"test"}, "acknowledgementDate"=>"2023-01-23T15:01:52Z", "items"=>[]}]}
        response = amazon_api.submit_acknowledgements(valid_req_body)
        expect(response).to eq mock_success_response

        stub_request(:post, "https://api.amazon.com/auth/o2/token").with(
          body: {
            "client_id"=>"#{ENV['AWS_ACCESS_KEY_ID']}",
            "client_secret"=>"#{ENV['AWS_SECRET_ACCESS_KEY']}",
            "grant_type"=>"refresh_token",
            "refresh_token"=>"dammy_refresh_token"
          },
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'=>'application/x-www-form-urlencoded',
            'Host'=>'api.amazon.com',
            'User-Agent'=>'Ruby'
          }
        ).to_return(status: 200, body: "", headers: {})
      end
    end
  end
end
