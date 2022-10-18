require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    context 'when user is logged in' do
      it "returns http success" do
        user = create(:user)
        sign_in user
        get "/pages/home"
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it "returns http success" do
        get "/pages/home"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

end
