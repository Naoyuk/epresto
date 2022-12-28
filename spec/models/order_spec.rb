# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'has a valid factory' do
    expect(build(:order)).to be_valid
  end

  # describe 'GET generate_access_token' do
  #   context 'when invalid params are given', :vcr do
  #     it 'returns errors' do
  #       access_token = Order.generate_access_token
  #       expect(access_token).not_to include('access_token')
  #       expect(access_token).to include('error_description')
  #     end
  #   end

  #   context 'when valid params are given', :vcr do
  #     it 'returns an access token' do
  #       Order.api_credentials
  #       access_token = Order.generate_access_token
  #       expect(access_token).to include('access_token')
  #       expect(access_token).not_to include('error_description')
  #     end
  #   end
  # end

  # describe 'GET get_purchase_orders' do
  #   context 'when valid params are given', :vcr do
  #     it 'returns 200 response' do
  #       params = {
  #         api: 'pos',
  #         path: '/vendor/orders/v1/purchaseOrders',
  #         created_after: Time.now - 7 * 24 * 3600,
  #         created_before: Time.now
  #       }
  #       res = Order.get_purchase_orders(params)
  #       expect(res.code).to eq '200'
  #     end
  #   end

  #   context 'when invalid params are given', :vcr do
  #     it 'does not return 200 response' do
  #       params = {
  #         api: 'pos',
  #         path: '/vendor/orders/v1/purchaseOrd',
  #         created_after: Time.now - 7 * 24 * 3600,
  #         created_before: Time.now
  #       }
  #       res = Order.get_purchase_orders(params)
  #       expect(res.code).not_to eq '200'
  #       expect(res.code).to eq '403'
  #     end
  #   end
  # end

  # describe '#formatted_query' do
  #   it 'クエリを渡すとソートされて返る' do
  #     query_hash = {
  #       'limit' => 50,
  #       'createdAfter' => Time.now - 7 * 24 * 3600,
  #       'sortOrder' => 'DESC',
  #       'createdBefor' => Time.now
  #     }
  #     query_should_be = "createdAfter=#{Time.now - 7 * 24 * 3600}&createdBefor=#{Time.now}&limit=50&sortOrder=DESC"
  #     query_formatted = Order.formatted_query(query_hash)
  #     expect(query_formatted).to eq query_should_be
  #   end
  # end
end
