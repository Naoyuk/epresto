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

  describe 'GET /show' do
    context 'when user is logged in' do
      it 'returns http success' do
        order = create(:order)
        user = create(:user)
        sign_in user
        get order_path order
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is logged in' do
      it 'returns http success' do
        order = create(:order)
        get order_path order
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
