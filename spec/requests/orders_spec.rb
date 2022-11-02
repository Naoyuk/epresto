# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'GET /index' do
    context 'when user is logged in' do
      it 'returns http success' do
        user = create(:user)
        sign_in user
        get orders_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'returns http redirect' do
        get orders_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # describe 'GET /show' do
  #   it 'returns http success' do
  #     get '/orders/show'
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe 'GET /import' do
  #   it 'returns http success' do
  #     get '/orders/import'
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe 'GET /create' do
  #   it 'returns http success' do
  #     get '/orders/create'
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe 'GET /update' do
  #   it 'returns http success' do
  #     get '/orders/update'
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
