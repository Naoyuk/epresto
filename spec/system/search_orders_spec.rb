require 'rails_helper'

RSpec.describe "SearchOrders", type: :system do
  before do
    driven_by(:rack_test)

    @user = create(:user)
    create(:shipto)
    day_of_this_week = Time.zone.now.strftime('%F')
    day_of_last_week = Time.zone.now.ago(7.days).strftime('%F')
    @order_new_this_week = create(:order, po_state: 0, po_number: 'new-order-this-week', po_date: day_of_this_week)
    @order_new_last_week = create(:order, po_state: 0, po_number: 'new-order-last-week', po_date: day_of_last_week)

    @order_acknowledged_this_week = create(:order, po_state: 1, po_number: 'acknowledged-order-this-week', po_date: day_of_this_week)
    @order_acknowledged_last_week = create(:order, po_state: 1, po_number: 'acknowledged-order-last-week', po_date: day_of_last_week)

    @order_closed_this_week = create(:order, po_state: 2, po_number: 'closed-order-this-week', po_date: day_of_this_week)
    @order_closed_last_week = create(:order, po_state: 2, po_number: 'closed-order-last-week', po_date: day_of_last_week)

    @order_rejected_this_week = create(:order, po_state: 1, po_number: 'rejected-order-this-week', po_date: day_of_this_week)
    @order_item_rejected_this_week = create(:order_item, order_id: @order_rejected_this_week.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_rejected_this_week.id, acknowledgement_code: 2)
    @order_rejected_last_week = create(:order, po_state: 1, po_number: 'rejected-order-last-week', po_date: day_of_last_week)
    @order_item_rejected_last_week = create(:order_item, order_id: @order_rejected_last_week.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_rejected_last_week.id, acknowledgement_code: 2)

    @order_accepted_this_week = create(:order, po_state: 1, po_number: 'accepted-order-this-week', po_date: day_of_this_week)
    @order_item_accepted_this_week = create(:order_item, order_id: @order_accepted_this_week.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_accepted_this_week.id, acknowledgement_code: 0)
    @order_accepted_last_week = create(:order, po_state: 1, po_number: 'accepted-order-last-week', po_date: day_of_last_week)
    @order_item_accepted_last_week = create(:order_item, order_id: @order_accepted_last_week.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_accepted_last_week.id, acknowledgement_code: 0)
  end

  describe 'デフォルトで今週のOrderを対象、期間を指定するとその期間のOrderを対象とする' do
    scenario 'Allタブをアクティブにすると今週の全てのOrderが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブをアクティブにして先週の期間で検索すると先週の全てのOrderが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).to have_content @order_closed_last_week.po_number
      expect(page).to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブをアクティブにすると今週のOrder.po_stateがNewのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブをアクティブにして先週の期間で検索すると先週のOrder.po_stateがNewのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブをアクティブにすると今週のOrder.po_stateがAcknowledgedのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブをアクティブにして先週の期間で検索すると先週のOrder.po_stateがAcknowledgedのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).to have_content @order_accepted_last_week.po_number
    end

    scenario 'Rejectedタブをアクティブにすると今週のAcknowledgementをrejectされたOrderItemを含むOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'rejected')

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Rejectedタブをアクティブにして先週の期間で検索すると先週のAcknowledgementをrejectされたOrderItemを含むOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'rejected')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Closedタブをアクティブにすると今週のOrder.po_stateがClosedのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'closed')

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Closedタブをアクティブにして先週の期間で検索すると先週のOrder.po_stateがClosedのOrderのみが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'closed')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Bulkタブをアクティブにすると今週の全てのOrderを対象にBulk切り替えチェックが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'bulk')

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number

      expect(page).to have_button 'Convert to Bulk Order'
      expect(page).to have_button 'Convert to Regular Order'
    end

    scenario 'Bulkタブをアクティブにして先週の期間で検索すると先週の全てのOrderを対象にBulk切り替えチェックが表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'bulk')
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).to have_content @order_closed_last_week.po_number
      expect(page).to have_content @order_accepted_last_week.po_number

      expect(page).to have_button 'Convert to Bulk Order'
      expect(page).to have_button 'Convert to Regular Order'
    end
  end

  describe 'Allタブの表示中の検索は全てのStatusのOrderを対象とする' do
    scenario 'Allタブを表示中にPO Number new-order-this-week で検索するとnew-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'q_po_number_cont_any', with: 'new-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number new-order-last-week を先週の期間で検索するとnew-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'q_po_number_cont_any', with: 'new-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number acknowledged-order-this-week で検索するとacknowledged-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'acknowledged-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number acknowledged-order-last-week を先週の期間で検索するとacknowledged-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'acknowledged-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number closed-order-this-week で検索するとclosed-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'closed-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number closed-order-last-week を先週の期間で検索するとclosed-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'closed-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number rejected-order-this-week で検索するとrejected-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'rejected-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number rejected-order-last-week を先週の期間で検索するとrejected-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'rejected-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number accepted-order-this-week で検索するとaccepted-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'accepted-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number accepted-order-last-week を先週の期間で検索するとaccepted-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'accepted-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).to have_content @order_accepted_last_week.po_number
    end
  end

  describe 'Newタブの表示中の検索はStatusがNewのOrderを対象とする' do
    scenario 'Newタブを表示中にPO Number new-order-this-week で検索するとnew-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'new-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number new-order-last-week を先週の期間で検索するとnew-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'new-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number acknowledged-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'acknowledged-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number acknowledged-order-last-week を先週の期間で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'acknowledged-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number closed-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'closed-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number closed-order-last-week を先週の期間で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'closed-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number rejected-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'rejected-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number rejected-order-last-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'rejected-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number accepted-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'accepted-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number accepted-order-last-week を先週の期間で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'accepted-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end
  end

  describe 'Newタブの表示中の検索はStatusがNewのOrderを対象とする' do
    scenario 'Acknowledgedタブを表示中にPO Number new-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'new-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number new-order-last-week を先週の期間で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'new-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number acknowledged-order-this-week 検索するとacknowledged-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'acknowledged-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number acknowledged-order-last-week を先週の期間で検索するとacknowledged-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'acknowledged-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number closed-order-this-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'closed-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number closed-order-last-week で検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'closed-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number rejected-order-this-week で検索すると rejected-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'rejected-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number rejected-order-last-week を先週の期間で検索すると rejected-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'rejected-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number accepted-order-this-week で検索するとaccepted-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'accepted-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number accepted-order-last-week を先週の期間で検索するとaccepted-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'accepted-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).to have_content @order_accepted_last_week.po_number
    end
  end

  describe 'PO Numberの検索窓にスペース区切りで複数のPO Numberを入れるとOR検索する' do
    scenario 'Allタブを表示中にPO Number new-order-this-week acknowledged-order-this-weekを検索するとnew-order-this-weekとacknowledged-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number new-order-this-week new-order-last-weekを先週の期間で検索するとnew-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'new-order-this-week new-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number acknowledged-order-this-week rejected-order-this-weekを検索するとacknowledged-order-this-weekとrejected-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'acknowledged-order-this-week rejected-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Allタブを表示中にPO Number new-order-this-week acknowledged-order-this-week accepted-order-this-week を検索するとその3つだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'all')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week accepted-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number new-order-this-week acknowledged-order-this-week を検索するとnew-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number new-order-this-week new-order-last-week を先週の期間で検索するとnew-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'new-order-this-week new-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number acknowledged-order-this-week rejected-order-this-week を検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'acknowledged-order-this-week rejected-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Newタブを表示中にPO Number new-order-this-week acknowledged-order-this-week accepted-order-this-week を検索するとnew-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'new')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week rejected-order-this-week'
      click_button 'Search'

      expect(page).to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number new-order-this-week acknowledged-order-this-week を検索するとacknowledged-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number acknowledged-order-this-week acknowledged-order-last-week を先週の期間で検索するとacknowledged-order-last-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'acknowledged-order-this-week acknowledged-order-last-week'
      fill_in 'q_po_date_gteq', with: Time.zone.now.ago(7.days).strftime('%F')
      fill_in 'q_po_date_lteq', with: Time.zone.now.ago(1.days).strftime('%F')
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number new-order-this-week closed-order-this-week を検索すると何もヒットしない' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'new-order-this-week closed-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).not_to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).not_to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end

    scenario 'Acknowledgedタブを表示中にPO Number new-order-this-week acknowledged-order-this-week accepted-order-this-week を検索するとacknowledged-order-this-weekとaccepted-order-this-weekだけがヒットする' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'

      visit orders_path(tab: 'acknowledged')
      fill_in 'PO Number', with: 'new-order-this-week acknowledged-order-this-week accepted-order-this-week'
      click_button 'Search'

      expect(page).not_to have_content @order_new_this_week.po_number
      expect(page).to have_content @order_acknowledged_this_week.po_number
      expect(page).not_to have_content @order_rejected_this_week.po_number
      expect(page).not_to have_content @order_closed_this_week.po_number
      expect(page).to have_content @order_accepted_this_week.po_number

      expect(page).not_to have_content @order_new_last_week.po_number
      expect(page).not_to have_content @order_acknowledged_last_week.po_number
      expect(page).not_to have_content @order_rejected_last_week.po_number
      expect(page).not_to have_content @order_closed_last_week.po_number
      expect(page).not_to have_content @order_accepted_last_week.po_number
    end
  end
end
