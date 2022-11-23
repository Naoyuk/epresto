# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /show' do
    context 'when user is logged in' do
      it 'returns http success' do
        user = create(:user)
        sign_in user
        get profile_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        create(:user)
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /users' do
    # context 'when user is an admin' do
    #   it 'creates a user' do
    #     vendor = create(:vendor)
    #     admin_user = create(:sysadmin)
    #     sign_in admin_user
    #     expect {
    #       post users_path, params: {
    #         name: 'new test user',
    #         email: 'newtestemail@example.com',
    #         vendor_id: vendor.id,
    #         password: 'password',
    #         password_confirmation: 'password'
    #       }
    #     }.to change(User, :count).by(1)
    #   end
    # end

    context 'when user is not an admin' do
      it 'raise error CanCan::AccessDenied' do
        vendor = create(:vendor)
        user = create(:user)
        sign_in user
        expect {
          post users_path, params: {
            name: 'new user',
            email: 'newemail@example.com',
            vendor_id: vendor.id,
            password: 'password',
            password_confirmation: 'password'
          }
        }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
