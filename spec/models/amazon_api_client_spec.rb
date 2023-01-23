# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AmazonAPI, type: :model do
  describe 'GET generate_access_token' do
    context 'when invalid params are given' do
      it 'returns errors' do
        access_token = generate_access_token(refresh_token, client_id, clinet_secret)
        expect(access_token).not_to include('access_token')
        expect(access_token).to include('error_description')
      end
    end

    context 'when valid params are given' do
      it 'returns an access token' do
        Order.api_credentials
        access_token = generate_access_token(refresh_token, client_id, clinet_secret)
        expect(access_token).to include('access_token')
        expect(access_token).not_to include('error_description')
      end
    end
  end

  # describe 'Order.formatted_query' do
  #   it 'クエリを渡すとソートされて返る' do
  #     created_after = Time.now - 7 * 24 * 3600
  #     created_before = Time.now
  #     query_hash = {
  #       'limit' => 50,
  #       'createdAfter' => created_after,
  #       'sortOrder' => 'DESC',
  #       'createdBefor' => created_before
  #     }
  #     query_should_be = "createdAfter=#{created_after}&createdBefor=#{created_before}&limit=50&sortOrder=DESC"
  #     query_formatted = formatted_query(query_hash)
  #     expect(query_formatted).to eq query_should_be
  #   end
  # end
end
