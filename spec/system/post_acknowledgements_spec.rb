require 'rails_helper'

RSpec.describe "PostAcknowledgements", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'a user posts acknowledgement and creates acknowledgement data' do
    before do
      # 必要なデータを作成
      create(:vendor)
      @user = create(:user)
      create(:item, asin: 'B01LNRIIAB')
      create(:item, asin: 'B07DFVDRAB')
#
      # ログイン
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      # POを取得
      # click_link 'Purchase Order'
      # click_button 'Update'
    end

    context 'with correct request' do
      xit 'gets response with transactionId' do
        # 正しいRequestを作成
        # AcknowledgeAPIをキック
        # transactionIdが入ったresponseが返ってくる
      end
    end

    context 'with incorrect request' do
      xit 'gets response with errors' do
        # 不正なRequestを作成
        # AcknowledgeAPIをキック
        # errorsが入ったresponseが返ってくる
        # order/index viewにerror内容が表示される
      end
    end
  end

  describe 'acknowledgement updates po state and acknowledgement codes' do
    # 必要なデータを作成
    # ログイン
    context 'when item that is not available is contained' do
      xit 'a state of po will be Acknowledged and still be OPEN'
      xit 'the item will be rejected'
    end

    context 'when list price is different from item price' do
      xit 'a state of po will be Acknowledged and still be OPEN'
      xit 'the item will be accepted po and show alert'
    end
  end
end
