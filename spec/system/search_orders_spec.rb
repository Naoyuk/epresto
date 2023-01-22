require 'rails_helper'

RSpec.describe "SearchOrders", type: :system do
  before do
    driven_by(:rack_test)

    @user = create(:user)
    shipto = create(:shipto)
    @order_new = create(:order, po_state: 0, po_number: 'new-order')
    @order_acknowledged = create(:order, po_state: 1, po_number: 'acknowledged-order')
    @order_closed = create(:order, po_state: 2, po_number: 'closed-order')

    @order_rejected = create(:order, po_state: 0, po_number: 'rejected-order')
    @order_item_rejected = create(:order_item, order_id: @order_rejected.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_rejected.id, acknowledgement_code: 2)

    @order_accepted = create(:order, po_state: 1, po_number: 'accepted-order')
    @order_item_accepted = create(:order_item, order_id: @order_accepted.id)
    create(:order_item_acknowledgement, order_item_id: @order_item_accepted.id, acknowledgement_code: 0)
  end

  scenario 'Allタブをアクティブにすると全てのOrderが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')

    expect(page).to have_content @order_new.po_number
    expect(page).to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).to have_content @order_closed.po_number
    expect(page).to have_content @order_accepted.po_number
  end

  scenario 'NewタブをアクティブにするとOrder.po_stateがNewのOrderのみが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')

    expect(page).to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'AcknowledgedタブをアクティブにするとOrder.po_stateがAcknowledgedのOrderのみが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')

    expect(page).not_to have_content @order_new.po_number
    expect(page).to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).to have_content @order_accepted.po_number
  end

  scenario 'RejectedタブをアクティブにするとAcknowledgementをrejectされたOrderItemを含むOrderのみが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'rejected')

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'ClosedタブをアクティブにするとOrder.po_stateがClosedのOrderのみが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'closed')

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Bulkタブをアクティブにすると全てのOrderを対象にBulk切り替えチェックが表示される' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'bulk')

    expect(page).to have_content @order_new.po_number
    expect(page).to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).to have_content @order_closed.po_number
    expect(page).to have_content @order_accepted.po_number
    expect(page).to have_button 'Convert to Bulk Order'
    expect(page).to have_button 'Convert to Regular Order'
  end

  scenario 'Allタブを表示中にPO Number new-order で検索するとnew-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')
    fill_in 'PO Number', with: 'new-order'
    click_button 'Search'

    expect(page).to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Allタブを表示中にPO Number acknowledged-order で検索するとacknowledged-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')
    fill_in 'PO Number', with: 'acknowledged-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Allタブを表示中にPO Number closed-order で検索するとclosed-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')
    fill_in 'PO Number', with: 'closed-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Allタブを表示中にPO Number rejected-order で検索するとrejected-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')
    fill_in 'PO Number', with: 'rejected-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Allタブを表示中にPO Number accepted-order で検索するとaccepted-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'all')
    fill_in 'PO Number', with: 'accepted-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).to have_content @order_accepted.po_number
  end

  scenario 'Newタブを表示中にPO Number new-order で検索するとnew-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')
    fill_in 'PO Number', with: 'new-order'
    click_button 'Search'

    expect(page).to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Newタブを表示中にPO Number acknowledged-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')
    fill_in 'PO Number', with: 'acknowledged-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Newタブを表示中にPO Number closed-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')
    fill_in 'PO Number', with: 'closed-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Newタブを表示中にPO Number rejected-order で検索するとrejected-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')
    fill_in 'PO Number', with: 'rejected-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Newタブを表示中にPO Number accepted-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'new')
    fill_in 'PO Number', with: 'accepted-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Acknowledgedタブを表示中にPO Number new-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')
    fill_in 'PO Number', with: 'new-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Acknowledgedタブを表示中にPO Number acknowledged-order で検索するとacknowledged-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')
    fill_in 'PO Number', with: 'acknowledged-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Acknowledgedタブを表示中にPO Number closed-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')
    fill_in 'PO Number', with: 'closed-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Acknowledgedタブを表示中にPO Number rejected-order で検索すると何もヒットしない' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')
    fill_in 'PO Number', with: 'rejected-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).not_to have_content @order_accepted.po_number
  end

  scenario 'Acknowledgedタブを表示中にPO Number accepted-order で検索するとaccepted-orderだけがヒットする' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'

    visit orders_path(tab: 'acknowledged')
    fill_in 'PO Number', with: 'accepted-order'
    click_button 'Search'

    expect(page).not_to have_content @order_new.po_number
    expect(page).not_to have_content @order_acknowledged.po_number
    expect(page).not_to have_content @order_rejected.po_number
    expect(page).not_to have_content @order_closed.po_number
    expect(page).to have_content @order_accepted.po_number
  end
end
