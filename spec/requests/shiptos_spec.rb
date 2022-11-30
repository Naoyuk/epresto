require 'rails_helper'

RSpec.describe "Shiptos", type: :request do
  describe 'GET /index' do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }

    context 'when admin user is logged in' do
      it 'returns http success' do
        sign_in user
        get shiptos_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when non-admin user is logged in' do
      it 'returns http redirect' do
        sign_in non_admin_user
        get shiptos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        get shiptos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /show' do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }

    context 'when admin user is logged in' do
      it 'returns http success' do
        sign_in user
        get shipto_path(shipto.id)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when non-admin user is logged in' do
      it 'returns http redirect' do
        sign_in non_admin_user
        get shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        get shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /new" do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }

    context 'when admin user is logged in' do
      it 'returns http success' do
        sign_in user
        get new_shipto_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when non-admin user is logged in' do
      it 'returns http redirect' do
        sign_in non_admin_user
        get new_shipto_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        get new_shipto_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /edit" do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }

    context 'when admin user is logged in' do
      it 'returns http success' do
        sign_in user
        get edit_shipto_path(shipto)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when non-admin user is logged in' do
      it 'returns http redirect' do
        sign_in non_admin_user
        get edit_shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        get edit_shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /create" do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }

    context 'when admin user is logged in' do
      it 'returns http success' do
        sign_in user
        get edit_shipto_path(shipto)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when non-admin user is logged in' do
      it 'returns http redirect' do
        sign_in non_admin_user
        get edit_shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      it 'returns http success' do
        get edit_shipto_path(shipto)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /update" do
    let(:user) { create(:user, sysadmin: true) }
    let(:non_admin_user) { create(:user, sysadmin: false) }
    let(:shipto) { create(:shipto) }
    let(:valid_attributes) { FactoryBot.attributes_for(:shipto) }

    context 'with valid parameters' do
      before do
        @new_attributes = valid_attributes
        @new_attributes[:location_code] = 'ZZZ1'
      end

      it 'updates the requested location' do
        sign_in user
        patch shipto_url(shipto), params: { shipto: @new_attributes }
        shipto.reload
        expect(shipto.location_code).to eq 'ZZZ1'
      end
    end

    context 'when non-admin user is logged in' do
      before do
        @new_attributes = valid_attributes
        @new_attributes[:location_code] = 'ZZZ1'
      end

      it 'returns http redirect' do
        sign_in non_admin_user
        patch shipto_url(shipto), params: { shipto: @new_attributes }
        shipto.reload
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not logged in' do
      before do
        @new_attributes = valid_attributes
        @new_attributes[:location_code] = 'ZZZ1'
      end

      it 'returns http success' do
        patch shipto_url(shipto), params: { shipto: @new_attributes }
        shipto.reload
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
