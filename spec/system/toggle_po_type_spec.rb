require 'rails_helper'

RSpec.describe 'Toggle regular and bulk order', type: :system do
  let(:user) { create(:user) }

  scenario 'Batch check and convert all checked Orders to Bulk', js: true do
    login_and_visit_bulk_page
    setup_orders

    expect(order1.po_type).to eq 0
    expect(order2.po_type).to eq 0
    expect(order3.po_type).to eq 0

    check 'check-all'
    click 'Convert to Bulk Order'

    expect(order1.po_type).to eq 3
    expect(order2.po_type).to eq 3
    expect(order3.po_type).to eq 3
  end

  scenario 'Check individually and convert all checked Orders to Bulk', js: true do
  end

  scenario 'Batch check and convert all checked Orders to Regular', js: true do
  end

  scenario 'Check individually and convert all checked Orders to Regular', js: true do
  end

  def login_and_visit_bulk_page
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Purchase Order'
    click_link 'Bulk'
  end

  def setup_orders
    order1 = create(:order)
    order2 = create(:order)
    order3 = create(:order)
  end
end
