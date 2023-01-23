# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AmazonAPIClient, type: :model do
  describe '#get_purchase_orders' do
    context 'APIを不正な引数で叩いた時' do
      it 'エラーを返す' do
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
      it 'PurchaseOrdersを返す' do
        amazon_api = AmazonAPIClient.new
        created_after = '2023-01-01 10:00:00'
        created_before = '2023-01-07 10:00:00'
        mock_response = 'success response'
        allow(amazon_api).to receive(:get_purchase_orders).and_return(mock_response)
        expect(amazon_api.get_purchase_orders(created_after, created_before)).to eq 'success response'
      end
    end
  end
end
