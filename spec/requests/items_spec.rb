# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :request do
  describe 'GET /index' do
    context 'when user is logged in' do
      it 'returns http success' do
        user = create(:user, sysadmin: true)
        sign_in user
        get items_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when a non-admin user is logged in' do
      it 'returns http success' do
        user = create(:user)
        sign_in user
        get items_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http redirect' do
        get items_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
