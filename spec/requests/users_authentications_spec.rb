# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }

  describe 'GET #edit' do
    context 'when user is logged in' do
      before do
        sign_in user
      end

      it 'return 200 success' do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'redirect to log in page' do
        get edit_user_registration_path
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
