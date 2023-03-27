require 'rails_helper'

RSpec.describe "Orders一覧", type: :system do
  describe "SearchOrders" do
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

        po_numbers = [
          @order_new_this_week.po_number,
          @order_acknowledged_this_week.po_number,
          @order_rejected_this_week.po_number,
          @order_closed_this_week.po_number,
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number,
          @order_acknowledged_last_week.po_number,
          @order_rejected_last_week.po_number,
          @order_closed_last_week.po_number,
          @order_accepted_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number,
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number,
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_this_week.po_number,
          @order_rejected_this_week.po_number,
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_last_week.po_number,
          @order_rejected_last_week.po_number,
          @order_accepted_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_rejected_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_rejected_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_closed_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_closed_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number,
          @order_acknowledged_this_week.po_number,
          @order_rejected_this_week.po_number,
          @order_closed_this_week.po_number,
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number,
          @order_acknowledged_last_week.po_number,
          @order_rejected_last_week.po_number,
          @order_closed_last_week.po_number,
          @order_accepted_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_closed_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_closed_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_rejected_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_rejected_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_accepted_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        po_numbers = [
          @order_acknowledged_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        po_numbers = [
          @order_rejected_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_rejected_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_accepted_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number,
          @order_acknowledged_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_this_week.po_number,
          @order_rejected_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number,
          @order_acknowledged_this_week.po_number,
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_new_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        po_numbers = [
          @order_new_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        po_numbers = [
          @order_acknowledged_last_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
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

        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to eq []
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

        po_numbers = [
          @order_acknowledged_this_week.po_number,
          @order_accepted_this_week.po_number
        ]
        expect(find('#po_numbers_carton', visible: false).value.split(' ')).to match_array po_numbers
      end
    end
  end

  describe "Pagination" do
    before do
      # ステータスが1の40件のデータを作成する
      # ステータスが2の40件のデータを作成する
      driven_by(:rack_test)

      @user = create(:user)
      create(:shipto)
      day_of_this_week = Time.zone.now.strftime('%F')
      80.times do |num|
        create(:order, po_state: 0, po_number: "PO-#{80 - num}", po_date: day_of_this_week)
      end
    end

    scenario 'デフォルトはOrderの1件目から25件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')

      expect(page).to have_content("PO-", count: 25)
      expect(page).to have_content("PO-1")
      expect(page).to have_content("PO-10")
      expect(page).to have_content("PO-20")
      expect(page).to have_content("PO-25")
      expect(page).not_to have_content("PO-26")
      expect(page).not_to have_content("PO-30")
      expect(page).not_to have_content("PO-40")
      expect(page).not_to have_content("PO-50")
      expect(page).not_to have_content("PO-51")
      expect(page).not_to have_content("PO-60")
      expect(page).not_to have_content("PO-70")
      expect(page).not_to have_content("PO-75")
      expect(page).not_to have_content("PO-76")
      expect(page).not_to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end

    scenario '2ページを表示すると26件目から50件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')
      # このページを表示した直後の.pageの0番目はcurrentなので1番目をクリック
      find_link('2').click

      expect(page).to have_content("PO-", count: 25)
      expect(page).not_to have_content("PO-1")
      expect(page).not_to have_content("PO-10")
      expect(page).not_to have_content("PO-20")
      expect(page).not_to have_content("PO-25")
      expect(page).to have_content("PO-26")
      expect(page).to have_content("PO-30")
      expect(page).to have_content("PO-40")
      expect(page).to have_content("PO-50")
      expect(page).not_to have_content("PO-51")
      expect(page).not_to have_content("PO-60")
      expect(page).not_to have_content("PO-70")
      expect(page).not_to have_content("PO-75")
      expect(page).not_to have_content("PO-76")
      expect(page).not_to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end

    scenario '3ページを表示すると51件目から75件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')
      # このページを表示した直後の.pageの0番目はcurrentなので2番目をクリック
      find_link('3').click

      expect(page).to have_content("PO-", count: 25)
      expect(page).not_to have_content("PO-1")
      expect(page).not_to have_content("PO-10")
      expect(page).not_to have_content("PO-20")
      expect(page).not_to have_content("PO-25")
      expect(page).not_to have_content("PO-26")
      expect(page).not_to have_content("PO-30")
      expect(page).not_to have_content("PO-40")
      expect(page).not_to have_content("PO-50")
      expect(page).to have_content("PO-51")
      expect(page).to have_content("PO-60")
      expect(page).to have_content("PO-70")
      expect(page).to have_content("PO-75")
      expect(page).not_to have_content("PO-76")
      expect(page).not_to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end

    scenario '3ページを表示してから1ページ目を表示すると1件目から25件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')
      # 3ページ目を表示してから1ページ目を表示
      find_link('3').click
      find_link('1').click

      expect(page).to have_content("PO-", count: 25)
      expect(page).to have_content("PO-1")
      expect(page).to have_content("PO-10")
      expect(page).to have_content("PO-20")
      expect(page).to have_content("PO-25")
      expect(page).not_to have_content("PO-26")
      expect(page).not_to have_content("PO-30")
      expect(page).not_to have_content("PO-40")
      expect(page).not_to have_content("PO-50")
      expect(page).not_to have_content("PO-51")
      expect(page).not_to have_content("PO-60")
      expect(page).not_to have_content("PO-70")
      expect(page).not_to have_content("PO-75")
      expect(page).not_to have_content("PO-76")
      expect(page).not_to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end

    scenario '最初のページを表示すると1件目から25件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')
      # 3ページ目を表示してから最初のページを表示
      find_link('3').click
      find_link('First').click

      expect(page).to have_content("PO-", count: 25)
      expect(page).to have_content("PO-1")
      expect(page).to have_content("PO-10")
      expect(page).to have_content("PO-20")
      expect(page).to have_content("PO-25")
      expect(page).not_to have_content("PO-26")
      expect(page).not_to have_content("PO-30")
      expect(page).not_to have_content("PO-40")
      expect(page).not_to have_content("PO-50")
      expect(page).not_to have_content("PO-51")
      expect(page).not_to have_content("PO-60")
      expect(page).not_to have_content("PO-70")
      expect(page).not_to have_content("PO-75")
      expect(page).not_to have_content("PO-76")
      expect(page).not_to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end

    scenario '最終ページを表示すると76件目から80件目が表示される' do
      visit root_path
      click_link 'Sign in'
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_button 'Log in'
      visit orders_path(tab: 'all')
      # 最終ページを表示
      find_link('Last').click

      expect(page).not_to have_content("PO-", count: 25)
      expect(page).not_to have_content("PO-1")
      expect(page).not_to have_content("PO-10")
      expect(page).not_to have_content("PO-20")
      expect(page).not_to have_content("PO-25")
      expect(page).not_to have_content("PO-26")
      expect(page).not_to have_content("PO-30")
      expect(page).not_to have_content("PO-40")
      expect(page).not_to have_content("PO-50")
      expect(page).not_to have_content("PO-51")
      expect(page).not_to have_content("PO-60")
      expect(page).not_to have_content("PO-70")
      expect(page).not_to have_content("PO-75")
      expect(page).to have_content("PO-76")
      expect(page).to have_content("PO-80")

      po_numbers = (1..80).map { |num| "PO-#{num}" }
      expect(find('#po_numbers_carton', visible: false).value).to eq po_numbers.join(' ')
    end
  end
end
